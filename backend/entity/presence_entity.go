package entity

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Presence struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"presence_id"`
	EmployeeID  uuid.UUID `gorm:"type:uuid" json:"employee_id"`
	Employee    Employee  `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	DateIn      time.Time `json:"presence_date_in"`
	DateOut     time.Time `json:"presence_date_out"`
	PhotoIn     string    `json:"presence_photo_in"`
	PhotoOut    string    `json:"presence_photo_out"`
	LocationIn  string    `json:"presence_location_in"`
	LocationOut string    `json:"presence_location_out"`
}

func (p *Presence) BeforeCreate(tx *gorm.DB) error {
	defer func() {
		if err := recover(); err != nil {
			tx.Rollback()
		}
	}()

	p.ID = uuid.New()

	return nil
}
