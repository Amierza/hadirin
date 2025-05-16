package service

import (
	"context"

	"github.com/Amierza/hadirin/backend/dto"
	"github.com/Amierza/hadirin/backend/entity"
	"github.com/Amierza/hadirin/backend/helpers"
	"github.com/Amierza/hadirin/backend/repository"
	"github.com/google/uuid"
)

type (
	IUserService interface {
		// Authentication
		Register(ctx context.Context, req dto.UserRegisterRequest) (dto.AllUserResponse, error)
		Login(ctx context.Context, req dto.UserLoginRequest) (dto.UserLoginResponse, error)
		RefreshToken(ctx context.Context, req dto.RefreshTokenRequest) (dto.RefreshTokenResponse, error)

		// Position
		GetAllPositionWithPagination(ctx context.Context, req dto.PaginationRequest) (dto.PositionPaginationResponse, error)
	}

	UserService struct {
		userRepo   repository.IUserRepository
		jwtService IJWTService
	}
)

func NewUserService(userRepo repository.IUserRepository, jwtService IJWTService) *UserService {
	return &UserService{
		userRepo:   userRepo,
		jwtService: jwtService,
	}
}

// Authentication
func (us *UserService) Register(ctx context.Context, req dto.UserRegisterRequest) (dto.AllUserResponse, error) {
	if req.Name == "" || req.Email == "" || req.Password == "" || req.PositionID == uuid.Nil {
		return dto.AllUserResponse{}, dto.ErrFieldIsEmpty
	}

	if len(req.Name) < 5 {
		return dto.AllUserResponse{}, dto.ErrNameToShort
	}

	if !helpers.IsValidEmail(req.Email) {
		return dto.AllUserResponse{}, dto.ErrInvalidEmail
	}

	if len(req.Password) < 8 {
		return dto.AllUserResponse{}, dto.ErrPasswordToShort
	}

	_, flag, err := us.userRepo.CheckEmail(ctx, nil, req.Email)
	if err == nil || flag {
		return dto.AllUserResponse{}, dto.ErrEmailAlreadyExists
	}

	phoneNumberFormatted, err := helpers.StandardizePhoneNumber(req.PhoneNumber)
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrFormatPhoneNumber
	}

	position, err := us.userRepo.GetPositionByID(ctx, nil, req.PositionID.String())
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrPositionNotFound
	}

	role, err := us.userRepo.GetRoleByName(ctx, nil, "employee")
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrGetRoleFromName
	}

	user := entity.User{
		ID:          uuid.New(),
		Name:        req.Name,
		Email:       req.Email,
		Password:    req.Password,
		PhoneNumber: phoneNumberFormatted,
		Position:    position,
		Role:        role,
	}

	newUser, err := us.userRepo.RegisterUser(ctx, nil, user)
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrRegisterUser
	}

	res := dto.AllUserResponse{
		ID:          newUser.ID,
		Name:        newUser.Name,
		Email:       newUser.Email,
		Password:    newUser.Password,
		PhoneNumber: newUser.PhoneNumber,
		Photo:       newUser.Photo,
		IsVerified:  newUser.IsVerified,
		Position: dto.PositionResponse{
			ID:   newUser.PositionID,
			Name: newUser.Position.Name,
		},
		Role: dto.RoleResponse{
			ID:   newUser.RoleID,
			Name: newUser.Role.Name,
		},
	}

	return res, nil
}
func (us *UserService) Login(ctx context.Context, req dto.UserLoginRequest) (dto.UserLoginResponse, error) {
	if req.Email == "" || req.Password == "" {
		return dto.UserLoginResponse{}, dto.ErrFieldIsEmpty
	}

	if !helpers.IsValidEmail(req.Email) {
		return dto.UserLoginResponse{}, dto.ErrInvalidEmail
	}

	user, flag, err := us.userRepo.CheckEmail(ctx, nil, req.Email)
	if err != nil || !flag {
		return dto.UserLoginResponse{}, dto.ErrEmailNotRegistered
	}

	checkPassword, err := helpers.CheckPassword(user.Password, []byte(req.Password))
	if err != nil || !checkPassword {
		return dto.UserLoginResponse{}, dto.ErrPasswordNotMatch
	}

	role, err := us.userRepo.GetRoleByName(ctx, nil, "employee")
	if err != nil {
		return dto.UserLoginResponse{}, dto.ErrGetRoleFromName
	}

	if role.Name != "employee" {
		return dto.UserLoginResponse{}, dto.ErrDeniedAccess
	}

	permissions, err := us.userRepo.GetPermissionsByRoleID(ctx, nil, user.RoleID.String())
	if err != nil {
		return dto.UserLoginResponse{}, dto.ErrGetPermissionsByRoleID
	}

	accessToken, refreshToken, err := us.jwtService.GenerateToken(user.ID.String(), user.RoleID.String(), permissions)
	if err != nil {
		return dto.UserLoginResponse{}, dto.ErrGenerateToken
	}

	return dto.UserLoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
func (us *UserService) RefreshToken(ctx context.Context, req dto.RefreshTokenRequest) (dto.RefreshTokenResponse, error) {
	_, err := us.jwtService.ValidateToken(req.RefreshToken)

	if err != nil {
		return dto.RefreshTokenResponse{}, dto.ErrValidateToken
	}

	userID, err := us.jwtService.GetUserIDByToken(req.RefreshToken)
	if err != nil {
		return dto.RefreshTokenResponse{}, dto.ErrGetUserIDFromToken
	}

	roleID, err := us.jwtService.GetRoleIDByToken(req.RefreshToken)
	if err != nil {
		return dto.RefreshTokenResponse{}, dto.ErrGetRoleIDFromToken
	}

	role, err := us.userRepo.GetRoleByID(ctx, nil, roleID)
	if err != nil {
		return dto.RefreshTokenResponse{}, dto.ErrGetRoleFromID
	}

	if role.Name != "user" {
		return dto.RefreshTokenResponse{}, dto.ErrDeniedAccess
	}

	endpoints, err := us.userRepo.GetPermissionsByRoleID(ctx, nil, roleID)
	if err != nil {
		return dto.RefreshTokenResponse{}, dto.ErrGetPermissionsByRoleID
	}

	accessToken, _, err := us.jwtService.GenerateToken(userID, roleID, endpoints)
	if err != nil {
		return dto.RefreshTokenResponse{}, dto.ErrGenerateAccessToken
	}

	return dto.RefreshTokenResponse{AccessToken: accessToken}, nil
}

// Position
func (as *UserService) GetAllPositionWithPagination(ctx context.Context, req dto.PaginationRequest) (dto.PositionPaginationResponse, error) {
	dataWithPaginate, err := as.userRepo.GetAllPositionWithPagination(ctx, nil, req)
	if err != nil {
		return dto.PositionPaginationResponse{}, err
	}

	var datas []dto.PositionResponse
	for _, position := range dataWithPaginate.Positions {
		data := dto.PositionResponse{
			ID:   &position.ID,
			Name: position.Name,
		}

		datas = append(datas, data)
	}

	return dto.PositionPaginationResponse{
		Data: datas,
		PaginationResponse: dto.PaginationResponse{
			Page:    dataWithPaginate.Page,
			PerPage: dataWithPaginate.PerPage,
			MaxPage: dataWithPaginate.MaxPage,
			Count:   dataWithPaginate.Count,
		},
	}, nil
}
