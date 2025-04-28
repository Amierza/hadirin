package entity

import (
	"github.com/google/uuid"
)

type Role struct {
	ID   uuid.UUID `gorm:"type:uuid;primaryKey" json:"role_id"`
	Name string    `json:"role_name"`

	Users       []User       `gorm:"foreignKey:RoleID"`
	Permissions []Permission `gorm:"foreignKey:RoleID"`

	TimeStamp
}
