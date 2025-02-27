package entity

import (
	"time"

	"github.com/Amierza/hadirin/backend/helpers"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID          uuid.UUID  `gorm:"type:uuid;primaryKey" json:"user_id"`
	Name        string     `json:"user_name"`
	Email       string     `gorm:"unique; not null" json:"user_email"`
	Password    string     `json:"user_password"`
	Birthdate   *time.Time `gorm:"type:date" json:"user_birth_date,omitempty"`
	PhoneNumber string     `json:"user_phone_number,omitempty"`
	Role        int        `json:"user_role"`
	IsVerified  bool       `json:"is_verified"`

	TimeStamp
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	defer func() {
		if err := recover(); err != nil {
			tx.Rollback()
		}
	}()

	u.ID = uuid.New()

	var err error
	u.Password, err = helpers.HashPassword(u.Password)
	if err != nil {
		return err
	}

	return nil
}
