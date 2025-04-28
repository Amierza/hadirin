package migrations

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"reflect"

	"github.com/Amierza/hadirin/backend/helpers"
	"gorm.io/gorm"
)

func SeedFromJSON[T any](db *gorm.DB, filePath string, model T, uniqueFields ...string) error {
	jsonFile, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file %s: %w", filePath, err)
	}
	defer jsonFile.Close()

	jsonData, err := io.ReadAll(jsonFile)
	if err != nil {
		return fmt.Errorf("failed to read JSON data: %w", err)
	}

	var listData []T
	if err := json.Unmarshal(jsonData, &listData); err != nil {
		return fmt.Errorf("failed to unmarshal JSON data: %w", err)
	}

	if err := db.AutoMigrate(&model); err != nil {
		return fmt.Errorf("failed to migrate model: %w", err)
	}

	for _, data := range listData {
		query := db.Model(&model)

		if len(uniqueFields) > 0 {
			for _, field := range uniqueFields {
				val := reflect.ValueOf(data)
				if val.Kind() == reflect.Ptr {
					val = val.Elem()
				}
				f := val.FieldByName(field)
				if !f.IsValid() {
					return fmt.Errorf("field %s not found in model", field)
				}
				query = query.Where(fmt.Sprintf("%s = ?", helpers.SnakeCase(field)), f.Interface())
			}
		}

		var existing T
		err := query.First(&existing).Error
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			continue
		}

		if err := db.Create(&data).Error; err != nil {
			return fmt.Errorf("failed to insert data: %w", err)
		}
	}

	return nil
}
