package entity

import (
	"github.com/Amierza/hadirin/backend/helpers"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"user_id"`
	Name        string    `gorm:"not null" json:"user_name"`
	Email       string    `gorm:"unique; not null" json:"user_email"`
	Password    string    `gorm:"not null" json:"user_password"`
	PhoneNumber string    `json:"user_phone_number"`
	Photo       string    `json:"user_photo"`
	IsVerified  bool      `json:"user_is_verified"`

	RoleID     *uuid.UUID `gorm:"type:uuid" json:"role_id"`
	Role       Role       `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	PositionID *uuid.UUID `gorm:"type:uuid" json:"position_id"`
	Position   Position   `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`

	Attendances []Attendance `gorm:"foreginKey:UserId"`
	Permits     []Permit     `gorm:"foreginKey:UserId"`

	TimeStamp
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	defer func() {
		if err := recover(); err != nil {
			tx.Rollback()
		}
	}()

	var err error
	u.Password, err = helpers.HashPassword(u.Password)
	if err != nil {
		return err
	}

	return nil
}
