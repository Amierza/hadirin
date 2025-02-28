package migrations

import (
	"github.com/Amierza/hadirin/backend/migrations/seed"
	"gorm.io/gorm"
)

func Seed(db *gorm.DB) error {
	if err := seed.ListEmployeeSeeder(db); err != nil {
		return err
	}

	return nil
}
