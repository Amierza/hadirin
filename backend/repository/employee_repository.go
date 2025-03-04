package repository

import (
	"context"

	"github.com/Amierza/hadirin/backend/entity"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type (
	IEmployeeRepository interface {
		CheckEmail(ctx context.Context, tx *gorm.DB, email string) (entity.Employee, bool, error)
		RegisterEmployee(ctx context.Context, tx *gorm.DB, employee entity.Employee) (entity.Employee, error)
		GetPositionByID(ctx context.Context, tx *gorm.DB, positionID uuid.UUID) (entity.Position, bool, error)
	}

	EmployeeRepository struct {
		db *gorm.DB
	}
)

func NewEmployeeRepository(db *gorm.DB) *EmployeeRepository {
	return &EmployeeRepository{
		db: db,
	}
}

func (er *EmployeeRepository) CheckEmail(ctx context.Context, tx *gorm.DB, email string) (entity.Employee, bool, error) {
	if tx == nil {
		tx = er.db
	}

	var employee entity.Employee
	if err := tx.WithContext(ctx).Where("email = ?", email).Take(&employee).Error; err != nil {
		return entity.Employee{}, false, err
	}

	return employee, true, nil
}

func (er *EmployeeRepository) RegisterEmployee(ctx context.Context, tx *gorm.DB, employee entity.Employee) (entity.Employee, error) {
	if tx == nil {
		tx = er.db
	}

	if err := tx.WithContext(ctx).Create(&employee).Error; err != nil {
		return entity.Employee{}, err
	}

	return employee, nil
}

func (er *EmployeeRepository) GetPositionByID(ctx context.Context, tx *gorm.DB, positionID uuid.UUID) (entity.Position, bool, error) {
	if tx == nil {
		tx = er.db
	}

	var position entity.Position
	if err := tx.WithContext(ctx).Where("id = ?", positionID).Take(&position).Error; err != nil {
		return entity.Position{}, false, err
	}

	return position, true, nil
}
