package service

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

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
		GetAllPosition(ctx context.Context) (dto.PositionsResponse, error)

		// User
		GetDetailUser(ctx context.Context) (dto.AllUserResponse, error)
		UpdateUser(ctx context.Context, req dto.UpdateUserRequest) (dto.AllUserResponse, error)

		// Attendance
		CreateAttendance(ctx context.Context, req dto.CreateAttendanceInRequest) (dto.AttendanceInResponse, error)

		// Permit
		CreatePermit(ctx context.Context, req dto.PermitRequest) (dto.PermitResponse, error)
		GetAllPermit(ctx context.Context, req dto.PermitMonthRequest) (dto.PermitsResponse, error)
		GetDetailPermit(ctx context.Context, permitID string) (dto.PermitResponse, error)
		UpdatePermit(ctx context.Context, req dto.PermitRequest) (dto.PermitResponse, error)
		DeletePermit(ctx context.Context, permitID string) (dto.PermitResponse, error)
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

	_, flag, err := us.userRepo.GetUserByEmail(ctx, nil, req.Email)
	if err == nil || flag {
		return dto.AllUserResponse{}, dto.ErrEmailAlreadyExists
	}

	phoneNumberFormatted, err := helpers.StandardizePhoneNumber(req.PhoneNumber)
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrFormatPhoneNumber
	}

	position, flag, err := us.userRepo.GetPositionByID(ctx, nil, req.PositionID.String())
	if err != nil || !flag {
		return dto.AllUserResponse{}, dto.ErrPositionNotFound
	}

	role, flag, err := us.userRepo.GetRoleByName(ctx, nil, "user")
	if err != nil || !flag {
		return dto.AllUserResponse{}, dto.ErrGetRoleFromName
	}

	user := entity.User{
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

	user, flag, err := us.userRepo.GetUserByEmail(ctx, nil, req.Email)
	if err != nil || !flag {
		return dto.UserLoginResponse{}, dto.ErrEmailNotRegistered
	}

	checkPassword, err := helpers.CheckPassword(user.Password, []byte(req.Password))
	if err != nil || !checkPassword {
		return dto.UserLoginResponse{}, dto.ErrPasswordNotMatch
	}

	role, flag, err := us.userRepo.GetRoleByName(ctx, nil, "user")
	if err != nil || !flag {
		return dto.UserLoginResponse{}, dto.ErrGetRoleFromName
	}

	if role.Name != "user" {
		return dto.UserLoginResponse{}, dto.ErrDeniedAccess
	}

	permissions, flag, err := us.userRepo.GetPermissionsByRoleID(ctx, nil, user.RoleID.String())
	if err != nil || !flag {
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

	role, flag, err := us.userRepo.GetRoleByID(ctx, nil, roleID)
	if err != nil || !flag {
		return dto.RefreshTokenResponse{}, dto.ErrGetRoleFromID
	}

	if role.Name != "user" {
		return dto.RefreshTokenResponse{}, dto.ErrDeniedAccess
	}

	endpoints, flag, err := us.userRepo.GetPermissionsByRoleID(ctx, nil, roleID)
	if err != nil || !flag {
		return dto.RefreshTokenResponse{}, dto.ErrGetPermissionsByRoleID
	}

	accessToken, _, err := us.jwtService.GenerateToken(userID, roleID, endpoints)
	if err != nil {
		return dto.RefreshTokenResponse{}, dto.ErrGenerateAccessToken
	}

	return dto.RefreshTokenResponse{AccessToken: accessToken}, nil
}

// Position
func (as *UserService) GetAllPosition(ctx context.Context) (dto.PositionsResponse, error) {
	dataWithPaginate, err := as.userRepo.GetAllPosition(ctx, nil)
	if err != nil {
		return dto.PositionsResponse{}, err
	}

	var datas []dto.PositionResponse
	for _, position := range dataWithPaginate.Positions {
		data := dto.PositionResponse{
			ID:   &position.ID,
			Name: position.Name,
		}

		datas = append(datas, data)
	}

	return dto.PositionsResponse{
		Data: datas,
	}, nil
}

// User
func (us *UserService) GetDetailUser(ctx context.Context) (dto.AllUserResponse, error) {
	token := ctx.Value("Authorization").(string)

	userId, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrGetUserIDFromToken
	}

	user, flag, err := us.userRepo.GetUserByID(ctx, nil, userId)
	if err != nil || !flag {
		return dto.AllUserResponse{}, dto.ErrUserNotFound
	}

	return dto.AllUserResponse{
		ID:          user.ID,
		Name:        user.Name,
		Email:       user.Email,
		Password:    user.Password,
		PhoneNumber: user.PhoneNumber,
		IsVerified:  user.IsVerified,
		Position: dto.PositionResponse{
			ID:   user.PositionID,
			Name: user.Position.Name,
		},
		Role: dto.RoleResponse{
			ID:   user.RoleID,
			Name: user.Role.Name,
		},
	}, nil
}
func (us *UserService) UpdateUser(ctx context.Context, req dto.UpdateUserRequest) (dto.AllUserResponse, error) {
	token := ctx.Value("Authorization").(string)
	userID, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrGetUserIDFromToken
	}

	user, flag, err := us.userRepo.GetUserByID(ctx, nil, userID)
	if err != nil || !flag {
		return dto.AllUserResponse{}, dto.ErrUserNotFound
	}

	if req.PositionID != nil {
		position, flag, err := us.userRepo.GetPositionByID(ctx, nil, req.PositionID.String())
		if err != nil || !flag {
			return dto.AllUserResponse{}, dto.ErrPositionNotFound
		}

		user.Position = position
	}

	if req.RoleID != nil {
		role, flag, err := us.userRepo.GetRoleByID(ctx, nil, req.RoleID.String())
		if err != nil || !flag {
			return dto.AllUserResponse{}, dto.ErrGetRoleFromID
		}

		user.Role = role
	}

	if req.Name != "" {
		if len(req.Name) < 5 {
			return dto.AllUserResponse{}, dto.ErrNameToShort
		}

		user.Name = req.Name
	}

	if req.Email != "" {
		if !helpers.IsValidEmail(req.Email) {
			return dto.AllUserResponse{}, dto.ErrInvalidEmail
		}

		_, flag, err := us.userRepo.GetUserByEmail(ctx, nil, req.Email)
		if flag || err == nil {
			return dto.AllUserResponse{}, dto.ErrEmailAlreadyExists
		}

		user.Email = req.Email
	}

	if req.Photo != "" {
		user.Photo = req.Photo
	}

	if req.PhoneNumber != "" {
		phoneNumberFormatted, err := helpers.StandardizePhoneNumber(req.PhoneNumber)
		if err != nil {
			return dto.AllUserResponse{}, dto.ErrFormatPhoneNumber
		}

		user.PhoneNumber = phoneNumberFormatted
	}

	err = us.userRepo.UpdateUser(ctx, nil, user)
	if err != nil {
		return dto.AllUserResponse{}, dto.ErrUpdateUser
	}

	res := dto.AllUserResponse{
		ID:          user.ID,
		Name:        user.Name,
		Email:       user.Email,
		Password:    user.Password,
		PhoneNumber: user.PhoneNumber,
		IsVerified:  user.IsVerified,
		Position: dto.PositionResponse{
			ID:   user.PositionID,
			Name: user.Position.Name,
		},
		Role: dto.RoleResponse{
			ID:   user.RoleID,
			Name: user.Role.Name,
		},
	}

	return res, nil
}

// Attendance
func (us *UserService) CreateAttendance(ctx context.Context, req dto.CreateAttendanceInRequest) (dto.AttendanceInResponse, error) {
	token := ctx.Value("Authorization").(string)
	userId, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return dto.AttendanceInResponse{}, dto.ErrGetUserIDFromToken
	}

	user, flag, err := us.userRepo.GetUserByID(ctx, nil, userId)
	if err != nil || !flag {
		return dto.AttendanceInResponse{}, dto.ErrUserNotFound
	}

	if req.LatitudeIn == "" || req.LongitudeIn == "" || req.FileHeader == nil {
		return dto.AttendanceInResponse{}, dto.ErrFieldIsEmpty
	}

	formatDate, err := helpers.FormatDate(req.DateIn)
	if err != nil {
		return dto.AttendanceInResponse{}, dto.ErrFormatDate
	}

	ext := strings.TrimPrefix(filepath.Ext(req.FileHeader.Filename), ".")
	if ext != "jpg" && ext != "jpeg" && ext != "png" {
		return dto.AttendanceInResponse{}, dto.ErrInvalidExtensionPhoto
	}

	fileName := fmt.Sprintf("%s_%s.%s",
		strings.ReplaceAll(strings.ToLower(user.Name), " ", "_"),
		time.Now().Format("20060102_150405"),
		ext,
	)

	_ = os.MkdirAll("assets", os.ModePerm)
	savePath := fmt.Sprintf("assets/%s", fileName)

	out, err := os.Create(savePath)
	if err != nil {
		return dto.AttendanceInResponse{}, dto.ErrCreateFile
	}
	defer out.Close()

	if _, err := io.Copy(out, req.FileReader); err != nil {
		return dto.AttendanceInResponse{}, dto.ErrSaveFile
	}

	attendance := entity.Attendance{
		ID:          uuid.New(),
		DateIn:      &formatDate,
		PhotoIn:     fileName,
		LatitudeIn:  req.LatitudeIn,
		LongitudeIn: req.LongitudeIn,
		UserID:      &user.ID,
	}

	if err := us.userRepo.CreateAttendance(ctx, nil, attendance); err != nil {
		return dto.AttendanceInResponse{}, dto.ErrCreateAttendance
	}

	return dto.AttendanceInResponse{
		ID:          attendance.ID,
		DateIn:      *attendance.DateIn,
		PhotoIn:     attendance.PhotoIn,
		LatitudeIn:  attendance.LatitudeIn,
		LongitudeIn: attendance.LongitudeIn,
	}, nil
}

// Permit
func (us *UserService) CreatePermit(ctx context.Context, req dto.PermitRequest) (dto.PermitResponse, error) {
	token := ctx.Value("Authorization").(string)
	userId, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return dto.PermitResponse{}, dto.ErrGetUserIDFromToken
	}

	if req.Date == "" || req.Status == nil || req.Title == "" || req.Desc == "" {
		return dto.PermitResponse{}, dto.ErrFieldIsEmpty
	}

	if len(req.Title) < 5 {
		return dto.PermitResponse{}, dto.ErrTitleToShort
	}

	if len(req.Desc) < 15 {
		return dto.PermitResponse{}, dto.ErrDescToShort
	}

	_, flag, err := us.userRepo.GetUserByID(ctx, nil, userId)
	if err != nil || !flag {
		return dto.PermitResponse{}, dto.ErrUserNotFound
	}

	userID, err := uuid.Parse(userId)
	if err != nil {
		return dto.PermitResponse{}, err
	}

	t, err := helpers.ParseDate(req.Date)
	if err != nil {
		return dto.PermitResponse{}, dto.ErrFormatDate
	}

	permit := entity.Permit{
		ID:     uuid.New(),
		Date:   *t,
		Status: *req.Status,
		Title:  req.Title,
		Desc:   req.Desc,
		UserID: &userID,
	}

	err = us.userRepo.CreatePermit(ctx, nil, permit)
	if err != nil {
		return dto.PermitResponse{}, dto.ErrCreatePermit
	}

	res := dto.PermitResponse{
		ID:     permit.ID,
		Date:   permit.Date,
		Status: permit.Status,
		Title:  permit.Title,
		Desc:   permit.Desc,
	}

	return res, nil
}
func (us *UserService) GetAllPermit(ctx context.Context, req dto.PermitMonthRequest) (dto.PermitsResponse, error) {
	token := ctx.Value("Authorization").(string)

	userID, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return dto.PermitsResponse{}, dto.ErrGetUserIDFromToken
	}

	userEntity, flag, err := us.userRepo.GetUserByID(ctx, nil, userID)
	if err != nil || !flag {
		return dto.PermitsResponse{}, dto.ErrUserNotFound
	}

	data, err := us.userRepo.GetAllPermit(ctx, nil, userID, req)
	if err != nil {
		return dto.PermitsResponse{}, dto.ErrGetAllPermit
	}

	user := dto.AllUserResponse{
		ID:          userEntity.ID,
		Name:        userEntity.Name,
		Email:       userEntity.Email,
		Password:    userEntity.Password,
		PhoneNumber: userEntity.PhoneNumber,
		Photo:       userEntity.Photo,
		IsVerified:  userEntity.IsVerified,
		Position: dto.PositionResponse{
			ID:   &userEntity.Position.ID,
			Name: userEntity.Position.Name,
		},
		Role: dto.RoleResponse{
			ID:   &userEntity.ID,
			Name: userEntity.Name,
		},
	}

	var permits []dto.PermitResponse
	for _, permit := range data.Permits {
		data := dto.PermitResponse{
			ID:     permit.ID,
			Date:   permit.Date,
			Status: permit.Status,
			Title:  permit.Title,
			Desc:   permit.Desc,
		}

		permits = append(permits, data)
	}

	return dto.PermitsResponse{
		User:    user,
		Permits: permits,
	}, nil
}
func (us *UserService) GetDetailPermit(ctx context.Context, permitID string) (dto.PermitResponse, error) {
	permit, flag, err := us.userRepo.GetPermitByID(ctx, nil, permitID)
	if err != nil || !flag {
		return dto.PermitResponse{}, dto.ErrPermitNotFound
	}

	return dto.PermitResponse{
		ID:     permit.ID,
		Date:   permit.Date,
		Status: permit.Status,
		Title:  permit.Title,
		Desc:   permit.Desc,
	}, nil
}
func (us *UserService) UpdatePermit(ctx context.Context, req dto.PermitRequest) (dto.PermitResponse, error) {
	permit, flag, err := us.userRepo.GetPermitByID(ctx, nil, req.ID)
	if err != nil || !flag {
		return dto.PermitResponse{}, dto.ErrPermitNotFound
	}

	if req.Title != "" {
		if len(req.Title) < 5 {
			return dto.PermitResponse{}, dto.ErrTitleToShort
		}

		permit.Title = req.Title
	}

	if req.Desc != "" {
		if len(req.Desc) < 15 {
			return dto.PermitResponse{}, dto.ErrDescToShort
		}

		permit.Desc = req.Desc
	}

	if req.Date != "" {
		t, err := helpers.ParseDate(req.Date)
		if err != nil {
			return dto.PermitResponse{}, dto.ErrFormatDate
		}

		permit.Date = *t
	}

	if req.Status != nil {
		permit.Status = *req.Status
	}

	err = us.userRepo.UpdatePermit(ctx, nil, permit)
	if err != nil {
		return dto.PermitResponse{}, dto.ErrCreatePermit
	}

	res := dto.PermitResponse{
		ID:     permit.ID,
		Date:   permit.Date,
		Status: permit.Status,
		Title:  permit.Title,
		Desc:   permit.Desc,
	}

	return res, nil
}
func (us *UserService) DeletePermit(ctx context.Context, permitID string) (dto.PermitResponse, error) {
	permit, flag, err := us.userRepo.GetPermitByID(ctx, nil, permitID)
	if err != nil || !flag {
		return dto.PermitResponse{}, dto.ErrPermitNotFound
	}

	err = us.userRepo.DeletePermit(ctx, nil, permitID)
	if err != nil {
		return dto.PermitResponse{}, dto.ErrCreatePermit
	}

	res := dto.PermitResponse{
		ID:     permit.ID,
		Date:   permit.Date,
		Status: permit.Status,
		Title:  permit.Title,
		Desc:   permit.Desc,
	}

	return res, nil
}
