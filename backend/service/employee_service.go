package service

import (
	"context"
	"regexp"

	"github.com/Amierza/hadirin/backend/dto"
	"github.com/Amierza/hadirin/backend/entity"
	"github.com/Amierza/hadirin/backend/helpers"
	"github.com/Amierza/hadirin/backend/repository"
	"github.com/google/uuid"
)

type (
	IEmployeeService interface {
		Register(ctx context.Context, req dto.EmployeeRegisterRequest) (dto.EmployeeRegisterResponse, error)
		Login(ctx context.Context, req dto.EmployeeLoginRequest) (dto.EmployeeLoginResponse, error)
	}

	EmployeeService struct {
		employeeRepo repository.IEmployeeRepository
		jwtService   IJWTService
	}
)

func NewEmployeeService(employeeRepo repository.IEmployeeRepository, jwtService IJWTService) *EmployeeService {
	return &EmployeeService{
		employeeRepo: employeeRepo,
		jwtService:   jwtService,
	}
}

func (es *EmployeeService) Register(ctx context.Context, req dto.EmployeeRegisterRequest) (dto.EmployeeRegisterResponse, error) {
	if req.Name == "" || req.Email == "" || req.Password == "" || req.PositionID == uuid.Nil {
		return dto.EmployeeRegisterResponse{}, dto.ErrFieldIsEmpty
	}

	if len(req.Name) < 5 {
		return dto.EmployeeRegisterResponse{}, dto.ErrNameToShort
	}

	if !isValidEmail(req.Email) {
		return dto.EmployeeRegisterResponse{}, dto.ErrInvalidEmail
	}

	if len(req.Password) < 8 {
		return dto.EmployeeRegisterResponse{}, dto.ErrPasswordToShort
	}

	_, flag, err := es.employeeRepo.CheckEmail(ctx, nil, req.Email)
	if err == nil || flag {
		return dto.EmployeeRegisterResponse{}, dto.ErrEmailAlreadyExists
	}

	position, flag, err := es.employeeRepo.GetPositionByID(ctx, nil, req.PositionID)
	if !flag || err != nil {
		return dto.EmployeeRegisterResponse{}, dto.ErrPositionNotFound
	}

	employee := entity.Employee{
		PositionID: position.ID,
		Position:   position,
		Name:       req.Name,
		Email:      req.Email,
		Password:   req.Password,
	}

	newEmployee, err := es.employeeRepo.RegisterEmployee(ctx, nil, employee)
	if err != nil {
		return dto.EmployeeRegisterResponse{}, dto.ErrRegisterEmployee
	}

	return dto.EmployeeRegisterResponse{
		ID:       newEmployee.ID,
		Name:     newEmployee.Name,
		Email:    newEmployee.Email,
		Password: newEmployee.Password,
		Position: employee.Position,
	}, nil
}

func isValidEmail(email string) bool {
	re := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return re.MatchString(email)
}

func (eh *EmployeeService) Login(ctx context.Context, req dto.EmployeeLoginRequest) (dto.EmployeeLoginResponse, error) {
	if req.Email == "" || req.Password == "" {
		return dto.EmployeeLoginResponse{}, dto.ErrFieldIsEmpty
	}

	if !isValidEmail(req.Email) {
		return dto.EmployeeLoginResponse{}, dto.ErrInvalidEmail
	}

	employee, flag, err := eh.employeeRepo.CheckEmail(ctx, nil, req.Email)
	if err != nil || !flag {
		return dto.EmployeeLoginResponse{}, dto.ErrEmailNotRegistered
	}

	checkPassword, err := helpers.CheckPassword(employee.Password, []byte(req.Password))
	if err != nil || !checkPassword {
		return dto.EmployeeLoginResponse{}, dto.ErrPasswordNotMatch
	}

	accessToken, refreshToken, err := eh.jwtService.GenerateToken(employee.ID.String())
	if err != nil {
		return dto.EmployeeLoginResponse{}, dto.ErrGenerateToken
	}

	return dto.EmployeeLoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
