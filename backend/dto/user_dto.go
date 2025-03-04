package dto

import (
	"errors"

	"github.com/Amierza/hadirin/backend/entity"
	"github.com/google/uuid"
)

const (
	// failed
	MESSAGE_FAILED_GET_DATA_FROM_BODY  = "gagal mendapatkan data dari body"
	MESSAGE_FAILED_PROSES_REQUEST      = "gagal memproses permintaan"
	MESSAGE_FAILED_TOKEN_NOT_FOUND     = "gagal, token tidak ditemukan"
	MESSAGE_FAILED_TOKEN_NOT_VALID     = "gagal, token tidak valid"
	MESSAGE_FAILED_TOKEN_DENIED_ACCESS = "gagal, akses token ditolak"
	MESSAGE_FAILED_REGISTER_EMPLOYEE   = "gagal mendaftarkan karyawan"
	MESSAGE_FAILED_LOGIN_EMPLOYEE      = "gagal login karyawan"

	// success
	MESSAGE_SUCCESS_REGISTER_EMPLOYEE = "berhasil mendaftarkan karyawan"
	MESSAGE_SUCCESS_LOGIN_EMPLOYEE    = "berhasil login karyawan"
)

var (
	ErrFieldIsEmpty       = errors.New("ada kolom yang kosong")
	ErrNameToShort        = errors.New("nama minimal 5 karakter")
	ErrInvalidEmail       = errors.New("email tidak valid")
	ErrPasswordToShort    = errors.New("password minimal 8 karakter")
	ErrHashingPassword    = errors.New("gagal hashing password")
	ErrEmailAlreadyExists = errors.New("email sudah terdaftar")
	ErrRegisterEmployee   = errors.New("gagal mendaftarkan karyawan")
	ErrPositionNotFound   = errors.New("gagal mendapatkan position")
	ErrEmailNotRegistered = errors.New("gagal, email tidak terdaftar")
	ErrPasswordNotMatch   = errors.New("gagal, password salah")
	ErrGenerateToken      = errors.New("gagal membuat token")
)

type (
	EmployeeRegisterRequest struct {
		Name       string    `json:"name" form:"name"`
		Email      string    `json:"email" form:"email"`
		Password   string    `json:"password" form:"password"`
		PositionID uuid.UUID `json:"position_id" form:"position_id"`
	}

	EmployeeRegisterResponse struct {
		ID       uuid.UUID       `json:"employee_id"`
		Name     string          `json:"employee_name"`
		Email    string          `json:"employee_email"`
		Password string          `json:"employee_password"`
		Position entity.Position `json:"position"`
	}

	EmployeeLoginRequest struct {
		Email    string `json:"email" form:"email"`
		Password string `json:"password" form:"password"`
	}

	EmployeeLoginResponse struct {
		AccessToken  string `json:"access_token"`
		RefreshToken string `json:"refresh_token"`
	}
)
