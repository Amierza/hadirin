package migrations

import (
	"github.com/Amierza/hadirin/backend/entity"
	"gorm.io/gorm"
)

func Seed(db *gorm.DB) error {
	err := SeedFromJSON[entity.Role](db, "./migrations/json/roles.json", entity.Role{}, "Name")
	if err != nil {
		return err
	}

	err = SeedFromJSON[entity.Position](db, "./migrations/json/positions.json", entity.Position{}, "Name")
	if err != nil {
		return err
	}

	err = SeedFromJSON[entity.User](db, "./migrations/json/users.json", entity.User{}, "Email")
	if err != nil {
		return err
	}

	err = SeedFromJSON[entity.Permission](db, "./migrations/json/permissions.json", entity.Permission{}, "RoleID", "Endpoint")
	if err != nil {
		return err
	}

	err = SeedFromJSON[entity.Permit](db, "./migrations/json/permits.json", entity.Permit{}, "UserID", "Title")
	if err != nil {
		return err
	}

	return nil
}
