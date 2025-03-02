package repository

import "gorm.io/gorm"

type (
	IUserRepository interface {
	}

	UserRepository struct {
		db *gorm.DB
	}
)

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{
		db: db,
	}
}
