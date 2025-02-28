package entity

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Permission struct {
	ID     uuid.UUID `gorm:"type:uuid;primaryKey" json:"permission_id"`
	Date   time.Time `json:"permission_date"`
	Status int       `json:"permission_status"`
	Title  string    `json:"permission_title"`
	Desc   string    `json:"permission_desc"`

	TimeStamp
}

func (p *Permission) BeforeCreate(tx *gorm.DB) error {
	defer func() {
		if err := recover(); err != nil {
			tx.Rollback()
		}
	}()

	p.ID = uuid.New()

	return nil
}
