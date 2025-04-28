package entity

import "github.com/google/uuid"

type Permission struct {
	ID       uuid.UUID `gorm:"type:uuid;primaryKey" json:"permission_id"`
	Endpoint string    `json:"permission_endpoint"`

	RoleID *uuid.UUID `gorm:"type:uuid" json:"role_id"`
	Role   Role       `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`

	TimeStamp
}
