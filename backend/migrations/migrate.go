package migrations

import (
	"github.com/Amierza/hadirin/backend/entity"
	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	if err := db.AutoMigrate(
		&entity.Position{},
		&entity.Employee{},
		&entity.Presence{},
		&entity.Permission{},
	); err != nil {
		return err
	}

	return nil
}
