package repository

import (
	"context"

	"github.com/Amierza/hadirin/backend/dto"
	"github.com/Amierza/hadirin/backend/entity"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type (
	IUserRepository interface {
		// GET / Read
		CheckEmail(ctx context.Context, tx *gorm.DB, email string) (entity.User, bool, error)
		GetPositionByID(ctx context.Context, tx *gorm.DB, positionID string) (entity.Position, error)
		GetRoleByName(ctx context.Context, tx *gorm.DB, roleName string) (entity.Role, error)
		GetPermissionsByRoleID(ctx context.Context, tx *gorm.DB, roleID string) ([]string, error)
		GetAllPosition(ctx context.Context, tx *gorm.DB) (dto.AllPositionRepositoryResponse, error)
		GetRoleByID(ctx context.Context, tx *gorm.DB, roleID string) (entity.Role, error)
		GetUserByID(ctx context.Context, tx *gorm.DB, userID string) (entity.User, error)
		GetAllPermit(ctx context.Context, tx *gorm.DB, userID string, req dto.PermitMonthRequest) (dto.AllPermitRepositoryResponse, error)

		// POST / Create
		RegisterUser(ctx context.Context, tx *gorm.DB, user entity.User) (entity.User, error)
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

// GET / Read
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
func (ur *UserRepository) GetAllPosition(ctx context.Context, tx *gorm.DB) (dto.AllPositionRepositoryResponse, error) {
	if tx == nil {
		tx = ur.db
	}

	var positions []entity.Position
	var err error

	if err := tx.WithContext(ctx).Model(&entity.Position{}).Order("created_at DESC").Find(&positions).Error; err != nil {
		return dto.AllPositionRepositoryResponse{}, err
	}

	return dto.AllPositionRepositoryResponse{
		Positions: positions,
	}, err
}
func (ur *UserRepository) GetRoleByID(ctx context.Context, tx *gorm.DB, roleID string) (entity.Role, error) {
	if tx == nil {
		tx = ur.db
	}

	var role entity.Role
	if err := tx.WithContext(ctx).Where("id = ?", roleID).Take(&role).Error; err != nil {
		return entity.Role{}, err
	}

	return role, nil
}
func (ur *UserRepository) GetUserByID(ctx context.Context, tx *gorm.DB, userID string) (entity.User, error) {
	if tx == nil {
		tx = ur.db
	}

	var user entity.User
	if err := tx.WithContext(ctx).Preload("Position").Preload("Role").Where("id = ?", userID).Take(&user).Error; err != nil {
		return entity.User{}, err
	}

	return user, nil
}
func (ur *UserRepository) GetAllPermit(ctx context.Context, tx *gorm.DB, userID string, req dto.PermitMonthRequest) (dto.AllPermitRepositoryResponse, error) {
	if tx == nil {
		tx = ur.db
	}

	var permits []entity.Permit
	var err error

	query := tx.WithContext(ctx).Model(&entity.Permit{}).Preload("User.Position").Preload("User.Role").Where("user_id = ?", userID)

	if req.Month != "" {
		validMonths := map[string]bool{
			"01": true, "02": true, "03": true, "04": true, "05": true, "06": true,
			"07": true, "08": true, "09": true, "10": true, "11": true, "12": true,
		}
		if validMonths[req.Month] {
			query = query.Where("EXTRACT(MONTH FROM created_at) = ?", req.Month)
		}
	}

	if err := query.Order("created_at DESC").Find(&permits).Error; err != nil {
		return dto.AllPermitRepositoryResponse{}, err
	}

	return dto.AllPermitRepositoryResponse{
		Permits: permits,
	}, err
}

// POST / Create
func (ur *UserRepository) RegisterUser(ctx context.Context, tx *gorm.DB, user entity.User) (entity.User, error) {
	if tx == nil {
		tx = ur.db
	}

	var newUser entity.User
	user.ID = uuid.New()
	if err := tx.WithContext(ctx).Create(&user).Take(&newUser).Error; err != nil {
		return entity.User{}, err
	}

	return user, nil
}
