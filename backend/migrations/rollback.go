package migrations

import (
	"github.com/Amierza/hadirin/backend/entity"
	"gorm.io/gorm"
)

func Rollback(db *gorm.DB) error {
	tables := []interface{}{
		&entity.Permission{},
		&entity.Presence{},
		&entity.Employee{},
		&entity.Position{},
	}

	for _, table := range tables {
		if err := db.Migrator().DropTable(table); err != nil {
			return err
		}
	}

	return nil
}
