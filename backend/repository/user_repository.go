package repository

import (
	"context"
	"math"
	"strings"

	"github.com/Amierza/hadirin/backend/dto"
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
		GetAllPositionWithPagination(ctx context.Context, tx *gorm.DB, req dto.PaginationRequest) (dto.AllPositionRepositoryResponse, error)
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

func (ar *UserRepository) GetAllPositionWithPagination(ctx context.Context, tx *gorm.DB, req dto.PaginationRequest) (dto.AllPositionRepositoryResponse, error) {
	if tx == nil {
		tx = ar.db
	}

	var positions []entity.Position
	var err error
	var count int64

	if req.PerPage == 0 {
		req.PerPage = 10
	}

	if req.Page == 0 {
		req.Page = 1
	}

	query := tx.WithContext(ctx).Model(&entity.Position{})

	if req.Search != "" {
		searchValue := "%" + strings.ToLower(req.Search) + "%"
		query = query.Where("LOWER(name) LIKE ?", searchValue)
	}

	if err := query.Count(&count).Error; err != nil {
		return dto.AllPositionRepositoryResponse{}, err
	}

	if err := query.Order("created_at DESC").Scopes(Paginate(req.Page, req.PerPage)).Find(&positions).Error; err != nil {
		return dto.AllPositionRepositoryResponse{}, err
	}

	totalPage := int64(math.Ceil(float64(count) / float64(req.PerPage)))

	return dto.AllPositionRepositoryResponse{
		Positions: positions,
		PaginationResponse: dto.PaginationResponse{
			Page:    req.Page,
			PerPage: req.PerPage,
			MaxPage: totalPage,
			Count:   count,
		},
	}, err
}
