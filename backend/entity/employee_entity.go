package entity

import (
	"time"

	"github.com/Amierza/hadirin/backend/helpers"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Employee struct {
	ID          uuid.UUID  `gorm:"type:uuid;primaryKey" json:"employee_id"`
	PositionID  *uuid.UUID `gorm:"type:uuid" json:"position_id"`
	Position    Position   `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	Name        string     `gorm:"not null" json:"employee_name"`
	Email       string     `gorm:"unique; not null" json:"employee_email"`
	Password    string     `gorm:"not null" json:"employee_password"`
	PhoneNumber string     `json:"employee_phone_number,omitempty"`
	Photo       *time.Time `json:"employee_photo,omitempty"`
	Role        int        `gorm:"unique; not null" json:"employee_role"`
	IsVerified  bool       `json:"is_verified"`

	TimeStamp
}

func (e *Employee) BeforeCreate(tx *gorm.DB) error {
	defer func() {
		if err := recover(); err != nil {
			tx.Rollback()
		}
	}()

	e.ID = uuid.New()

	var err error
	e.Password, err = helpers.HashPassword(e.Password)
	if err != nil {
		return err
	}

	return nil
}
