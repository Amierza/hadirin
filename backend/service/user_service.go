package service

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/Amierza/hadirin/backend/constants"
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
		GetAllAttendance(ctx context.Context) ([]dto.AttendanceOutResponse, error)
		GetAttendanceToday(ctx context.Context, req dto.AttendanceTodayRequest) (dto.AttendanceOutResponse, error)

		// Attendance
		CreateAttendance(ctx context.Context, req dto.CreateAttendanceInRequest) (dto.AttendanceInResponse, error)
		UpdateAttendanceOut(ctx context.Context, req dto.UpdateAttendanceOutRequest) (dto.AttendanceOutResponse, error)

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

	if req.FileHeader != nil || req.FileReader != nil {
		ext := strings.TrimPrefix(filepath.Ext(req.FileHeader.Filename), ".")
		ext = strings.ToLower(ext)
		if ext != "jpg" && ext != "jpeg" && ext != "png" {
			return dto.AllUserResponse{}, dto.ErrInvalidExtensionPhoto
		}

		fileName := fmt.Sprintf("%s_warasin.%s",
			strings.ReplaceAll(strings.ToLower(user.Name), " ", "_"),
			ext,
		)

		_ = os.MkdirAll("assets/user", os.ModePerm)
		savePath := fmt.Sprintf("assets/user/%s", fileName)

		out, err := os.Create(savePath)
		if err != nil {
			return dto.AllUserResponse{}, dto.ErrCreateFile
		}
		defer out.Close()

		if _, err := io.Copy(out, req.FileReader); err != nil {
			return dto.AllUserResponse{}, dto.ErrSaveFile
		}
		user.Photo = fileName
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
		Photo:       user.Photo,
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

	if req.DateIn == "" || req.LatitudeIn == "" || req.LongitudeIn == "" || req.FileHeader == nil {
		return dto.AttendanceInResponse{}, dto.ErrFieldIsEmpty
	}

	formatDate, err := helpers.FormatDate(req.DateIn)
	if err != nil {
		return dto.AttendanceInResponse{}, dto.ErrFormatDate
	}

	loc, _ := time.LoadLocation("Asia/Jakarta")
	limitTime := time.Date(
		formatDate.Year(), formatDate.Month(), formatDate.Day(),
		7, 0, 0, 0, loc,
	)

	var status bool
	if formatDate.After(limitTime) {
		status = false
	} else {
		status = true
	}
	req.Status = &status

	if req.FileHeader != nil || req.FileReader != nil {
		ext := strings.TrimPrefix(filepath.Ext(req.FileHeader.Filename), ".")
		ext = strings.ToLower(ext)
		if ext != "jpg" && ext != "jpeg" && ext != "png" {
			return dto.AttendanceInResponse{}, dto.ErrInvalidExtensionPhoto
		}

		fileName := fmt.Sprintf("%s_%s.%s",
			strings.ReplaceAll(strings.ToLower(user.Name), " ", "_"),
			formatDate.Format("20060102_150405"),
			ext,
		)

		_ = os.MkdirAll("assets/attendance/attendance_in", os.ModePerm)
		savePath := fmt.Sprintf("assets/attendance/attendance_in/%s", fileName)

		out, err := os.Create(savePath)
		if err != nil {
			return dto.AttendanceInResponse{}, dto.ErrCreateFile
		}
		defer out.Close()

		if _, err := io.Copy(out, req.FileReader); err != nil {
			return dto.AttendanceInResponse{}, dto.ErrSaveFile
		}
		req.PhotoIn = fileName
	}

	latIn, err1 := strconv.ParseFloat(req.LatitudeIn, 64)
	lonIn, err2 := strconv.ParseFloat(req.LongitudeIn, 64)
	if err1 != nil || err2 != nil {
		return dto.AttendanceInResponse{}, dto.ErrInvalidCoordinate
	}

	distance := helpers.CalculateDistance(constants.OFFICE_LATITUDE, constants.OFFICE_LONGITUDE, latIn, lonIn)
	if distance > constants.ALLOWED_RADIUS {
		return dto.AttendanceInResponse{}, dto.ErrOutOfOfficeRadius
	}

	attendance := entity.Attendance{
		ID:          uuid.New(),
		Status:      req.Status,
		DateIn:      &formatDate,
		PhotoIn:     req.PhotoIn,
		LatitudeIn:  req.LatitudeIn,
		LongitudeIn: req.LongitudeIn,
		UserID:      &user.ID,
	}

	if err := us.userRepo.CreateAttendance(ctx, nil, attendance); err != nil {
		return dto.AttendanceInResponse{}, dto.ErrCreateAttendance
	}

	return dto.AttendanceInResponse{
		ID:          attendance.ID,
		Status:      attendance.Status,
		DateIn:      *attendance.DateIn,
		PhotoIn:     attendance.PhotoIn,
		LatitudeIn:  attendance.LatitudeIn,
		LongitudeIn: attendance.LongitudeIn,
	}, nil
}
func (us *UserService) UpdateAttendanceOut(ctx context.Context, req dto.UpdateAttendanceOutRequest) (dto.AttendanceOutResponse, error) {
	token := ctx.Value("Authorization").(string)
	userId, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrGetUserIDFromToken
	}

	user, flag, err := us.userRepo.GetUserByID(ctx, nil, userId)
	if err != nil || !flag {
		return dto.AttendanceOutResponse{}, dto.ErrUserNotFound
	}

	if req.DateOut == "" || req.LatitudeOut == "" || req.LongitudeOut == "" || req.FileHeader == nil {
		return dto.AttendanceOutResponse{}, dto.ErrFieldIsEmpty
	}

	attendance, flag, err := us.userRepo.GetAttendanceByID(ctx, nil, req.ID)
	if err != nil || !flag {
		return dto.AttendanceOutResponse{}, dto.ErrAttendanceNotFound
	}

	formatDate, err := helpers.FormatDate(req.DateOut)
	if err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrFormatDate
	}
	attendance.DateOut = &formatDate
	attendance.LatitudeOut = req.LatitudeOut
	attendance.LongitudeOut = req.LongitudeOut

	ext := strings.TrimPrefix(filepath.Ext(req.FileHeader.Filename), ".")
	ext = strings.ToLower(ext)
	if ext != "jpg" && ext != "jpeg" && ext != "png" {
		return dto.AttendanceOutResponse{}, dto.ErrInvalidExtensionPhoto
	}

	fileName := fmt.Sprintf("%s_%s.%s",
		strings.ReplaceAll(strings.ToLower(user.Name), " ", "_"),
		formatDate.Format("20060102_150405"),
		ext,
	)
	attendance.PhotoOut = fileName

	_ = os.MkdirAll("assets/attendance/attendance_out", os.ModePerm)
	savePath := fmt.Sprintf("assets/attendance/attendance_out/%s", fileName)

	out, err := os.Create(savePath)
	if err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrCreateFile
	}
	defer out.Close()

	if _, err := io.Copy(out, req.FileReader); err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrSaveFile
	}

	latOut, err1 := strconv.ParseFloat(req.LatitudeOut, 64)
	lonOut, err2 := strconv.ParseFloat(req.LongitudeOut, 64)
	if err1 != nil || err2 != nil {
		return dto.AttendanceOutResponse{}, dto.ErrInvalidCoordinate
	}

	distance := helpers.CalculateDistance(constants.OFFICE_LATITUDE, constants.OFFICE_LONGITUDE, latOut, lonOut)
	if distance > constants.ALLOWED_RADIUS {
		return dto.AttendanceOutResponse{}, dto.ErrOutOfOfficeRadius
	}

	if err := us.userRepo.UpdateAttendanceOut(ctx, nil, attendance); err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrUpdateAttendance
	}

	return dto.AttendanceOutResponse{
		ID:           attendance.ID,
		Status:       attendance.Status,
		DateIn:       *attendance.DateIn,
		DateOut:      *attendance.DateOut,
		PhotoIn:      attendance.PhotoIn,
		PhotoOut:     attendance.PhotoOut,
		LatitudeIn:   attendance.LatitudeIn,
		LongitudeIn:  attendance.LongitudeIn,
		LatitudeOut:  attendance.LatitudeOut,
		LongitudeOut: attendance.LongitudeOut,
	}, nil
}
func (us *UserService) GetAllAttendance(ctx context.Context) ([]dto.AttendanceOutResponse, error) {
	token := ctx.Value("Authorization").(string)

	userID, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return []dto.AttendanceOutResponse{}, dto.ErrGetUserIDFromToken
	}

	datas, err := us.userRepo.GetAllAttendance(ctx, nil, userID)
	if err != nil {
		return []dto.AttendanceOutResponse{}, dto.ErrGetAllAttendance
	}

	var attendances []dto.AttendanceOutResponse
	for _, attendance := range datas {
		attendances = append(attendances, dto.AttendanceOutResponse{
			ID:           attendance.ID,
			Status:       attendance.Status,
			DateIn:       *attendance.DateIn,
			DateOut:      *attendance.DateOut,
			PhotoIn:      attendance.PhotoIn,
			PhotoOut:     attendance.PhotoOut,
			LatitudeIn:   attendance.LatitudeIn,
			LongitudeIn:  attendance.LongitudeIn,
			LatitudeOut:  attendance.LatitudeOut,
			LongitudeOut: attendance.LongitudeOut,
		})
	}

	return attendances, nil
}
func (us *UserService) GetAttendanceToday(ctx context.Context, req dto.AttendanceTodayRequest) (dto.AttendanceOutResponse, error) {
	token := ctx.Value("Authorization").(string)

	userID, err := us.jwtService.GetUserIDByToken(token)
	if err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrGetUserIDFromToken
	}

	todayDate, err := helpers.ParseDateOnly(req.Date)
	if err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrFormatDate
	}

	att, err := us.userRepo.GetAttendanceToday(ctx, nil, userID, &todayDate)
	if err != nil {
		return dto.AttendanceOutResponse{}, dto.ErrGetAttendanceToday
	}

	attendance := dto.AttendanceOutResponse{
		ID:           att.ID,
		Status:       att.Status,
		DateIn:       *att.DateIn,
		DateOut:      *att.DateOut,
		PhotoIn:      att.PhotoIn,
		PhotoOut:     att.PhotoOut,
		LatitudeIn:   att.LatitudeIn,
		LongitudeIn:  att.LongitudeIn,
		LatitudeOut:  att.LatitudeOut,
		LongitudeOut: att.LongitudeOut,
	}

	return attendance, nil
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
