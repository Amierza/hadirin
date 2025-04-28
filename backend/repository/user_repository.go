package repository

import (
	"context"

	"github.com/Amierza/hadirin/backend/entity"
	"gorm.io/gorm"
)

type (
	IUserRepository interface {
		CheckEmail(ctx context.Context, tx *gorm.DB, email string) (entity.User, bool, error)
		RegisterUser(ctx context.Context, tx *gorm.DB, user entity.User) (entity.User, error)
		GetPositionByID(ctx context.Context, tx *gorm.DB, positionID string) (entity.Position, error)
		GetRoleByName(ctx context.Context, tx *gorm.DB, roleName string) (entity.Role, error)
		GetPermissionsByRoleID(ctx context.Context, tx *gorm.DB, roleID string) ([]string, error)
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

func (ur *UserRepository) CheckEmail(ctx context.Context, tx *gorm.DB, email string) (entity.User, bool, error) {
	if tx == nil {
		tx = ur.db
	}

	var user entity.User
	if err := tx.WithContext(ctx).Where("email = ?", email).Take(&user).Error; err != nil {
		return entity.User{}, false, err
	}

	return user, true, nil
}

func (ur *UserRepository) RegisterUser(ctx context.Context, tx *gorm.DB, user entity.User) (entity.User, error) {
	if tx == nil {
		tx = ur.db
	}

	var newUser entity.User
	if err := tx.WithContext(ctx).Create(&user).Take(&newUser).Error; err != nil {
		return entity.User{}, err
	}

	return user, nil
}

func (ur *UserRepository) GetPositionByID(ctx context.Context, tx *gorm.DB, positionID string) (entity.Position, error) {
	if tx == nil {
		tx = ur.db
	}

	var position entity.Position
	if err := tx.WithContext(ctx).Where("id = ?", positionID).Take(&position).Error; err != nil {
		return entity.Position{}, err
	}

	return position, nil
}

func (ur *UserRepository) GetRoleByName(ctx context.Context, tx *gorm.DB, roleName string) (entity.Role, error) {
	if tx == nil {
		tx = ur.db
	}

	var role entity.Role
	if err := tx.WithContext(ctx).Where("name = ?", roleName).Take(&role).Error; err != nil {
		return entity.Role{}, err
	}

	return role, nil
}

func (ur *UserRepository) GetPermissionsByRoleID(ctx context.Context, tx *gorm.DB, roleID string) ([]string, error) {
	if tx == nil {
		tx = ur.db
	}

	var endpoints []string
	if err := tx.WithContext(ctx).Table("permissions").Where("role_id = ?", roleID).Pluck("endpoint", &endpoints).Error; err != nil {
		return []string{}, err
	}

	return endpoints, nil
}
