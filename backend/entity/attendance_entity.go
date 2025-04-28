package entity

import (
	"time"

	"github.com/google/uuid"
)

type Attendance struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"attendance_id"`
	DateIn      time.Time `json:"attendance_date_in"`
	DateOut     time.Time `json:"attendance_date_out"`
	PhotoIn     string    `json:"attendance_photo_in"`
	PhotoOut    string    `json:"attendance_photo_out"`
	LocationIn  string    `json:"attendance_location_in"`
	LocationOut string    `json:"attendance_location_out"`

	UserID *uuid.UUID `gorm:"type:uuid" json:"user_id"`
	User   User       `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`

	TimeStamp
}
