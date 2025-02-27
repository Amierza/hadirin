package service

import (
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type (
	IJWTService interface {
		GenerateToken(userID string) (string, string, error)
		ValidateToken(token string) (*jwt.Token, error)
		GetUserIDByToken(tokenString string) (string, error)
	}

	jwtCustomClaim struct {
		UserID string `json:"user_id"`
		jwt.RegisteredClaims
	}

	JWTService struct {
		secretKey string
		issuer    string
	}
)

func NewJWTService() *JWTService {
	return &JWTService{
		secretKey: getSecretKey(),
		issuer:    "Template",
	}
}

func getSecretKey() string {
	secretKey := os.Getenv("JWT_SECRET")
	if secretKey == "" {
		secretKey = "Template"
	}

	return secretKey
}

func (j *JWTService) GenerateToken(userID string) (string, string, error) {
	accessClaims := jwtCustomClaim{
		userID,
		jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Second * 120)),
			Issuer:    j.issuer,
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessTokenString, err := accessToken.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", "", fmt.Errorf("failed to generate access token: %v", err)
	}

	refreshClaims := jwtCustomClaim{
		userID,
		jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Second * 3600 * 24 * 7)),
			Issuer:    j.issuer,
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshTokenString, err := refreshToken.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", "", fmt.Errorf("failed to generate refresh token: %v", err)
	}

	return accessTokenString, refreshTokenString, nil
}

func (j *JWTService) parseToken(t_ *jwt.Token) (any, error) {
	if _, ok := t_.Method.(*jwt.SigningMethodHMAC); !ok {
		return nil, fmt.Errorf("unexpected signing method: %v", t_.Header["alg"])
	}

	return []byte(j.secretKey), nil
}

func (j *JWTService) ValidateToken(tokenString string) (*jwt.Token, error) {
	token, err := jwt.Parse(tokenString, j.parseToken)
	if err != nil {
		return nil, err
	}

	return token, err
}

func (j *JWTService) GetUserIDByToken(tokenString string) (string, error) {
	token, err := j.ValidateToken(tokenString)
	if err != nil {
		return "", fmt.Errorf("error validating token: %v", err)
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return "", fmt.Errorf("invalid token: %v", err)
	}

	userID := fmt.Sprintf("%v", claims["user_id"])

	return userID, nil
}
