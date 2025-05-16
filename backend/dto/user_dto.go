package dto

import (
	"errors"
	"time"

	"github.com/Amierza/hadirin/backend/entity"
	"github.com/google/uuid"
)

const (
	// failed
	MESSAGE_FAILED_GET_DATA_FROM_BODY         = "gagal mendapatkan data dari body"
	MESSAGE_FAILED_PROSES_REQUEST             = "gagal memproses permintaan"
	MESSAGE_FAILED_TOKEN_NOT_FOUND            = "gagal, token tidak ditemukan"
	MESSAGE_FAILED_TOKEN_NOT_VALID            = "gagal, token tidak valid"
	MESSAGE_FAILED_TOKEN_DENIED_ACCESS        = "gagal, akses token ditolak"
	MESSAGE_FAILED_REGISTER_USER              = "gagal mendaftarkan user"
	MESSAGE_FAILED_LOGIN_USER                 = "gagal login user"
	MESSAGE_FAILED_GET_LIST_POSITION          = "gagal mendapatkan list posisi"
	MESSAGE_FAILED_REFRESH_TOKEN              = "gagal refresh token"
	MESSAGE_FAILED_INAVLID_ENPOINTS_TOKEN     = "gagal invalid endpoints di dalam token"
	MESSAGE_FAILED_INAVLID_ROUTE_FORMAT_TOKEN = "gagal invalid format route di dalamh token"
	MESSAGE_FAILED_ACCESS_DENIED              = "gagal akses ditolak"
	MESSAGE_FAILED_GET_DETAIL_USER            = "gagal mendapatkan user detail"
	MESSAGE_FAILED_GET_LIST_PERMIT            = "gagal mendapatkan list perizinan"

	// success
	MESSAGE_SUCCESS_REGISTER_USER     = "berhasil mendaftarkan user"
	MESSAGE_SUCCESS_LOGIN_USER        = "berhasil login user"
	MESSAGE_SUCCESS_GET_LIST_POSITION = "berhasil mendapatkan list posisi"
	MESSAGE_SUCCESS_REFRESH_TOKEN     = "berhasil refresh token"
	MESSAGE_SUCCESS_GET_DETAIL_USER   = "berhasil mendapatkan user detail"
	MESSAGE_SUCCESS_GET_LIST_PERMIT   = "berhasil mendapatkan list perizinan"
)

var (
	ErrFieldIsEmpty            = errors.New("ada kolom yang kosong")
	ErrNameToShort             = errors.New("nama minimal 5 karakter")
	ErrInvalidEmail            = errors.New("email tidak valid")
	ErrPasswordToShort         = errors.New("password minimal 8 karakter")
	ErrHashingPassword         = errors.New("gagal hashing password")
	ErrEmailAlreadyExists      = errors.New("email sudah terdaftar")
	ErrRegisterUser            = errors.New("gagal mendaftarkan user")
	ErrPositionNotFound        = errors.New("gagal mendapatkan position")
	ErrEmailNotRegistered      = errors.New("gagal email tidak terdaftar")
	ErrPasswordNotMatch        = errors.New("gagal password salah")
	ErrGenerateToken           = errors.New("gagal membuat token")
	ErrGenerateAccessToken     = errors.New("gagal generate access token")
	ErrGenerateRefreshToken    = errors.New("gagal generate refresh token")
	ErrUnexpectedSigningMethod = errors.New("gagal metode penandatanganan yang tidak terduga")
	ErrValidateToken           = errors.New("gagal validasi token")
	ErrTokenInvalid            = errors.New("token invalid")
	ErrFormatPhoneNumber       = errors.New("gagal menstandarisasi input nomor telepon")
	ErrGetRoleFromName         = errors.New("gagal mendapatkan role berdasarkan nama")
	ErrGetPermissionsByRoleID  = errors.New("gagal mendapatkan permission berdasarkan role id")
	ErrDeniedAccess            = errors.New("access ditolak")
	ErrGetUserIDFromToken      = errors.New("gagal mendapatkan user id dari token")
	ErrGetRoleIDFromToken      = errors.New("gagal mendapatkan role id dari token")
	ErrGetRoleFromID           = errors.New("gagal mendapatkan role dari id")
	ErrUserNotFound            = errors.New("gagal user tidak ditemukan")
	ErrGetAllPermit            = errors.New("gagal mendapatkan semua perizinan")
)

type (
	UserRegisterRequest struct {
		Name        string    `json:"name" form:"name"`
		Email       string    `json:"email" form:"email"`
		Password    string    `json:"password" form:"password"`
		PhoneNumber string    `json:"phone_number" form:"phone_number"`
		PositionID  uuid.UUID `json:"position_id" form:"position_id"`
	}

	AllUserResponse struct {
		ID          uuid.UUID        `json:"user_id"`
		Name        string           `json:"user_name"`
		Email       string           `json:"user_email"`
		Password    string           `json:"user_password"`
		PhoneNumber string           `json:"user_phone_number"`
		Photo       string           `json:"user_photo"`
		IsVerified  bool             `json:"user_is_verified"`
		Position    PositionResponse `json:"position"`
		Role        RoleResponse     `json:"role"`
	}

	UserLoginRequest struct {
		Email    string `json:"email" form:"email"`
		Password string `json:"password" form:"password"`
	}

	UserLoginResponse struct {
		AccessToken  string `json:"access_token"`
		RefreshToken string `json:"refresh_token"`
	}

	RoleResponse struct {
		ID   *uuid.UUID `json:"role_id"`
		Name string     `json:"role_name"`
	}

	PositionResponse struct {
		ID   *uuid.UUID `json:"position_id"`
		Name string     `json:"position_name"`
	}

	PositionsResponse struct {
		Data []PositionResponse `json:"data"`
	}

	AllPositionRepositoryResponse struct {
		Positions []entity.Position
	}

	RefreshTokenRequest struct {
		RefreshToken string `json:"refresh_token"`
	}

	RefreshTokenResponse struct {
		AccessToken string `json:"access_token"`
	}

	PermitResponse struct {
		ID     uuid.UUID       `json:"permit_id"`
		Date   time.Time       `json:"permit_date"`
		Status int             `json:"permit_status"`
		Title  string          `json:"permit_title"`
		Desc   string          `json:"permit_desc"`
		User   AllUserResponse `json:"user"`
	}

	PermitsResponse struct {
		Data []PermitResponse `json:"data"`
	}

	AllPermitRepositoryResponse struct {
		Permits []entity.Permit
	}

	PermitMonthRequest struct {
		Month string `form:"month"`
	}
)
