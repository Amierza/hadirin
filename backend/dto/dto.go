package dto

import (
	"errors"
	"mime/multipart"
	"time"

	"github.com/Amierza/hadirin/backend/entity"
	"github.com/google/uuid"
)

const (
	// ====================================== Failed ======================================
	MESSAGE_FAILED_GET_DATA_FROM_BODY = "gagal mendapatkan data dari body"
	MESSAGE_FAILED_PARSE_STATUS       = "gagal parse status"
	// File
	MESSAGE_FAILED_READ_PHOTO = "gagal membaca foto"
	MESSAGE_FAILED_OPEN_PHOTO = "gagal membuka foto"
	// Middleware
	MESSAGE_FAILED_PROSES_REQUEST             = "gagal memproses permintaan"
	MESSAGE_FAILED_TOKEN_NOT_FOUND            = "gagal, token tidak ditemukan"
	MESSAGE_FAILED_TOKEN_NOT_VALID            = "gagal, token tidak valid"
	MESSAGE_FAILED_TOKEN_DENIED_ACCESS        = "gagal, akses token ditolak"
	MESSAGE_FAILED_INAVLID_ENPOINTS_TOKEN     = "gagal invalid endpoints di dalam token"
	MESSAGE_FAILED_INAVLID_ROUTE_FORMAT_TOKEN = "gagal invalid format route di dalamh token"
	MESSAGE_FAILED_ACCESS_DENIED              = "gagal akses ditolak"
	// Authentication
	MESSAGE_FAILED_REGISTER_USER = "gagal mendaftarkan user"
	MESSAGE_FAILED_LOGIN_USER    = "gagal login user"
	MESSAGE_FAILED_REFRESH_TOKEN = "gagal refresh token"
	// Position
	MESSAGE_FAILED_GET_LIST_POSITION = "gagal mendapatkan list posisi"
	// User
	MESSAGE_FAILED_GET_DETAIL_USER = "gagal mendapatkan user detail"
	MESSAGE_FAILED_UPDATE_USER     = "gagal perbarui user"
	// Attendance
	MESSAGE_FAILED_CREATE_ATTENDANCE     = "gagal membuat presensi"
	MESSAGE_FAILED_UPDATE_ATTENDANCE_OUT = "gagal update presensi keluar"
	// Permit
	MESSAGE_FAILED_CREATE_PERMIT     = "gagal membuat perizinan"
	MESSAGE_FAILED_GET_LIST_PERMIT   = "gagal mendapatkan list perizinan"
	MESSAGE_FAILED_GET_DETAIL_PERMIT = "gagal mendapatkan perizinan"
	MESSAGE_FAILED_UPDATE_PERMIT     = "gagal perbarui perizinan"
	MESSAGE_FAILED_DELETE_PERMIT     = "gagal hapus perizinan"

	// ====================================== Success ======================================
	// Authentication
	MESSAGE_SUCCESS_REGISTER_USER = "berhasil mendaftarkan user"
	MESSAGE_SUCCESS_LOGIN_USER    = "berhasil login user"
	MESSAGE_SUCCESS_REFRESH_TOKEN = "berhasil refresh token"
	// Position
	MESSAGE_SUCCESS_GET_LIST_POSITION = "berhasil mendapatkan list posisi"
	// User
	MESSAGE_SUCCESS_GET_DETAIL_USER = "berhasil mendapatkan user detail"
	MESSAGE_SUCCESS_UPDATE_USER     = "berhasil perbarui user"
	// Attendance
	MESSAGE_SUCCESS_CREATE_ATTENDANCE     = "berhasil membuat presensi"
	MESSAGE_SUCCESS_UPDATE_ATTENDANCE_OUT = "berhasil update presensi keluar"
	// Permit
	MESSAGE_SUCCESS_CREATE_PERMIT     = "berhasil membuat perizinan"
	MESSAGE_SUCCESS_GET_LIST_PERMIT   = "berhasil mendapatkan list perizinan"
	MESSAGE_SUCCESS_GET_DETAIL_PERMIT = "berhasil mendapatkan perizinan"
	MESSAGE_SUCCESS_UPDATE_PERMIT     = "berhasil perbarui perizinan"
	MESSAGE_SUCCESS_DELETE_PERMIT     = "berhasil hapus perizinan"
)

var (
	// Input Validation
	ErrFieldIsEmpty      = errors.New("ada kolom yang kosong")
	ErrNameToShort       = errors.New("nama minimal 5 karakter")
	ErrInvalidEmail      = errors.New("email tidak valid")
	ErrPasswordToShort   = errors.New("password minimal 8 karakter")
	ErrFormatPhoneNumber = errors.New("gagal menstandarisasi input nomor telepon")
	ErrTitleToShort      = errors.New("judul perizinan minimal 5 karakter")
	ErrDescToShort       = errors.New("deskripsi perizinan minimal 15 karakter")
	// File
	ErrInvalidExtensionPhoto = errors.New("hanya jpg/png yang diperbolehkan")
	ErrCreateFile            = errors.New("gagal membuat file")
	ErrSaveFile              = errors.New("gagal menyimpan file")
	// Password
	ErrHashingPassword  = errors.New("gagal hashing password")
	ErrPasswordNotMatch = errors.New("gagal password salah")
	// Email
	ErrEmailAlreadyExists = errors.New("email sudah terdaftar")
	ErrEmailNotRegistered = errors.New("gagal email tidak terdaftar")
	// Authentication
	ErrRegisterUser = errors.New("gagal mendaftarkan user")
	// Position
	ErrPositionNotFound = errors.New("gagal mendapatkan position")
	// Token
	ErrGenerateToken           = errors.New("gagal membuat token")
	ErrGenerateAccessToken     = errors.New("gagal generate access token")
	ErrGenerateRefreshToken    = errors.New("gagal generate refresh token")
	ErrUnexpectedSigningMethod = errors.New("gagal metode penandatanganan yang tidak terduga")
	ErrValidateToken           = errors.New("gagal validasi token")
	ErrTokenInvalid            = errors.New("token invalid")
	// Role
	ErrGetRoleFromName    = errors.New("gagal mendapatkan role berdasarkan nama")
	ErrGetRoleIDFromToken = errors.New("gagal mendapatkan role id dari token")
	ErrGetRoleFromID      = errors.New("gagal mendapatkan role dari id")
	// Middleware
	ErrGetPermissionsByRoleID = errors.New("gagal mendapatkan permission berdasarkan role id")
	ErrDeniedAccess           = errors.New("access ditolak")
	// User
	ErrGetUserIDFromToken = errors.New("gagal mendapatkan user id dari token")
	ErrUserNotFound       = errors.New("gagal user tidak ditemukan")
	ErrUpdateUser         = errors.New("gagal perbarui user")
	// Attendance
	ErrCreateAttendance   = errors.New("gagal membuat presensi")
	ErrAttendanceNotFound = errors.New("gagal presensi tidak ditemukan")
	ErrUpdateAttendance   = errors.New("gagal update presensi keluar")
	ErrInvalidCoordinate  = errors.New("gagal koordinat tidak valid")
	ErrOutOfOfficeRadius  = errors.New("gagal lokasi berada di luar radius kantor")
	// Permit
	ErrCreatePermit   = errors.New("gagal membuat perizinan")
	ErrFormatDate     = errors.New("gagal memformat tanggal")
	ErrGetAllPermit   = errors.New("gagal mendapatkan semua perizinan")
	ErrPermitNotFound = errors.New("gagal perizinan tidak ditemukan")
)

type (
	// Authentication
	UserRegisterRequest struct {
		Name        string    `json:"name" form:"name"`
		Email       string    `json:"email" form:"email"`
		Password    string    `json:"password" form:"password"`
		PhoneNumber string    `json:"phone_number" form:"phone_number"`
		PositionID  uuid.UUID `json:"position_id" form:"position_id"`
	}
	UserLoginRequest struct {
		Email    string `json:"email" form:"email"`
		Password string `json:"password" form:"password"`
	}
	UserLoginResponse struct {
		AccessToken  string `json:"access_token"`
		RefreshToken string `json:"refresh_token"`
	}
	RefreshTokenRequest struct {
		RefreshToken string `json:"refresh_token"`
	}
	RefreshTokenResponse struct {
		AccessToken string `json:"access_token"`
	}
	// User
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
	UpdateUserRequest struct {
		Name        string     `json:"name,omitempty"`
		Email       string     `json:"email,omitempty"`
		Password    string     `json:"password,omitempty"`
		PhoneNumber string     `json:"phone_number,omitempty"`
		Photo       string     `json:"photo,omitempty"`
		RoleID      *uuid.UUID `json:"role_id,omitempty"`
		PositionID  *uuid.UUID `json:"position_id,omitempty"`
		FileHeader  *multipart.FileHeader
		FileReader  multipart.File
	}
	// Role
	RoleResponse struct {
		ID   *uuid.UUID `json:"role_id"`
		Name string     `json:"role_name"`
	}
	// Position
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
	// Attendance
	CreateAttendanceInRequest struct {
		ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"att_id"`
		Status      *bool     `json:"att_status"`
		DateIn      string    `json:"att_date_in"`
		PhotoIn     string    `json:"att_photo_in"`
		LatitudeIn  string    `json:"att_latitude_in"`
		LongitudeIn string    `json:"att_longitude_in"`
		FileHeader  *multipart.FileHeader
		FileReader  multipart.File
	}
	AttendanceInResponse struct {
		ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"att_id"`
		Status      *bool     `json:"att_status"`
		DateIn      time.Time `json:"att_date_in"`
		PhotoIn     string    `json:"att_photo_in"`
		LatitudeIn  string    `json:"att_latitude_in"`
		LongitudeIn string    `json:"att_longitude_in"`
	}
	UpdateAttendanceOutRequest struct {
		ID           string `json:"-"`
		Status       *bool  `json:"att_status"`
		DateOut      string `json:"att_date_out"`
		PhotoOut     string `json:"att_photo_out"`
		LatitudeOut  string `json:"att_latitude_out"`
		LongitudeOut string `json:"att_longitude_out"`
		FileHeader   *multipart.FileHeader
		FileReader   multipart.File
	}
	AttendanceOutResponse struct {
		ID           uuid.UUID `gorm:"type:uuid;primaryKey" json:"att_id"`
		Status       *bool     `json:"att_status"`
		DateIn       time.Time `json:"att_date_in"`
		DateOut      time.Time `json:"att_date_out"`
		PhotoIn      string    `json:"att_photo_in"`
		PhotoOut     string    `json:"att_photo_out"`
		LatitudeIn   string    `json:"att_latitude_in"`
		LongitudeIn  string    `json:"att_longitude_in"`
		LatitudeOut  string    `json:"att_latitude_out"`
		LongitudeOut string    `json:"att_longitude_out"`
	}
	// Permit
	PermitResponse struct {
		ID     uuid.UUID `json:"permit_id"`
		Date   time.Time `json:"permit_date"`
		Status int       `json:"permit_status"`
		Title  string    `json:"permit_title"`
		Desc   string    `json:"permit_desc"`
	}
	PermitsResponse struct {
		User    AllUserResponse  `json:"user"`
		Permits []PermitResponse `json:"permits"`
	}
	AllPermitRepositoryResponse struct {
		Permits []entity.Permit
	}
	PermitMonthRequest struct {
		Month string `form:"month"`
	}
	PermitRequest struct {
		ID     string `json:"-"`
		Date   string `json:"permit_date"`
		Status *int   `json:"permit_status"`
		Title  string `json:"permit_title"`
		Desc   string `json:"permit_desc"`
	}
	DeletePermitRequest struct {
		ID string `json:"-"`
	}
)
