package seed

import (
	"encoding/json"
	"errors"
	"io"
	"os"

	"github.com/Amierza/hadirin/backend/entity"
	"gorm.io/gorm"
)

func ListEmployeeSeeder(db *gorm.DB) error {
	jsonFile, err := os.Open("./migrations/json/employees.json")
	if err != nil {
		return err
	}

	jsonData, _ := io.ReadAll(jsonFile)

	var listEmployee []entity.User
	if err := json.Unmarshal(jsonData, &listEmployee); err != nil {
		return err
	}

	hasTable := db.Migrator().HasTable(&entity.User{})
	if !hasTable {
		if err := db.Migrator().CreateTable(&entity.User{}); err != nil {
			return err
		}
	}

	for _, data := range listEmployee {
		var employee entity.User
		err := db.Where(&entity.User{Email: data.Email}).First(&employee).Error
		if err != nil || !errors.Is(err, gorm.ErrRecordNotFound) {
			return err
		}

		isData := db.Find(&employee, "email = ?", data.Email).RowsAffected
		if isData == 0 {
			if err := db.Create(&data).Error; err != nil {
				return err
			}
		}
	}

	return nil
}
