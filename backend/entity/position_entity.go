package entity

import (
	"github.com/google/uuid"
)

type Position struct {
	ID   uuid.UUID `gorm:"type:uuid;primaryKey" json:"position_id"`
	Name string    `json:"position_name"`

	User []User `gorm:"foreignKey:PositionID"`

	TimeStamp
}
