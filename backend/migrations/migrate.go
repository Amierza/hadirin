package migrations

import (
	"github.com/Amierza/hadirin/backend/entity"
	"gorm.io/gorm"
)

func Migrate(db *gorm.DB) error {
	if err := db.AutoMigrate(
		&entity.Role{},
		&entity.Permission{},
		&entity.Position{},
		&entity.User{},
		&entity.Attendance{},
		&entity.Permit{},
	); err != nil {
		return err
	}

	return nil
}
