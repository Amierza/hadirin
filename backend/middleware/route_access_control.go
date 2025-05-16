package middleware

import (
	"net/http"
	"strings"

	"github.com/Amierza/hadirin/backend/dto"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/Amierza/hadirin/backend/utils"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func RouteAccessControl(jwtService service.IJWTService) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		authHeader := ctx.GetHeader("Authorization")
		if authHeader == "" {
			res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_TOKEN_NOT_FOUND, nil)
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, res)
			return
		}

		if !strings.Contains(authHeader, "Bearer") {
			res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_TOKEN_NOT_VALID, nil)
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, res)
			return
		}

		authHeader = strings.Replace(authHeader, "Bearer ", "", -1)
		token, err := jwtService.ValidateToken(authHeader)
		if err != nil {
			res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_TOKEN_NOT_VALID, nil)
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, res)
			return
		}

		if !token.Valid {
			res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_TOKEN_DENIED_ACCESS, nil)
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, res)
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_TOKEN_NOT_VALID, nil)
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, res)
			return
		}

		requestedPath := ctx.FullPath()
		rawAllowed, ok := claims["endpoints"].([]interface{})
		if !ok {
			res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_INAVLID_ENPOINTS_TOKEN, nil)
			ctx.AbortWithStatusJSON(http.StatusForbidden, res)
			return
		}

		allowedPath := make([]string, len(rawAllowed))
		for i, v := range rawAllowed {
			strVal, ok := v.(string)
			if !ok {
				res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_INAVLID_ROUTE_FORMAT_TOKEN, nil)
				ctx.AbortWithStatusJSON(http.StatusForbidden, res)
				return
			}
			allowedPath[i] = strVal
		}

		hasAccess := false
		for _, route := range allowedPath {
			if route == requestedPath {
				hasAccess = true
				break
			}
		}

		if !hasAccess {
			res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_PROSES_REQUEST, dto.MESSAGE_FAILED_ACCESS_DENIED, nil)
			ctx.AbortWithStatusJSON(http.StatusForbidden, res)
			return
		}

		ctx.Next()
	}
}
