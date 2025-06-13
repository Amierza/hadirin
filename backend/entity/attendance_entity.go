package entity

import (
	"time"

	"github.com/google/uuid"
)

type Attendance struct {
	ID           uuid.UUID  `gorm:"type:uuid;primaryKey" json:"att_id"`
	DateIn       *time.Time `json:"att_date_in"`
	DateOut      *time.Time `json:"att_date_out"`
	PhotoIn      string     `json:"att_photo_in"`
	PhotoOut     string     `json:"att_photo_out"`
	LatitudeIn   string     `json:"att_latitude_in"`
	LongitudeIn  string     `json:"att_longitude_in"`
	LatitudeOut  string     `json:"att_latitude_out"`
	LongitudeOut string     `json:"att_longitude_out"`

	UserID *uuid.UUID `gorm:"type:uuid" json:"user_id"`
	User   User       `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`

	TimeStamp
}
