package entity

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Position struct {
	ID        uuid.UUID  `gorm:"type:uuid;primaryKey" json:"position_id"`
	Name      string     `json:"position_name"`
	Employees []Employee `gorm:"foreignKey:PositionID"`

	TimeStamp
}

func (p *Position) BeforeCreate(tx *gorm.DB) error {
	defer func() {
		if err := recover(); err != nil {
			tx.Rollback()
		}
	}()

	p.ID = uuid.New()

	return nil
}
