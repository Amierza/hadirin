package entity

import (
	"time"

	"github.com/google/uuid"
)

type Permit struct {
	ID     uuid.UUID `gorm:"type:uuid;primaryKey" json:"permit_id"`
	Date   time.Time `json:"permit_date"`
	Status int       `json:"permit_status"`
	Title  string    `json:"permit_title"`
	Desc   string    `json:"permit_desc"`

	UserID *uuid.UUID `gorm:"type:uuid" json:"user_id"`
	User   User       `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`

	TimeStamp
}
