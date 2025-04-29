package routes

import (
	"github.com/Amierza/hadirin/backend/handler"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/gin-gonic/gin"
)

func User(route *gin.Engine, userHandler handler.IUserHandler, jwtService service.IJWTService) {
	routes := route.Group("/api/v1/user")
	{
		routes.POST("/register", userHandler.Register)
		routes.POST("/login", userHandler.Login)
		routes.GET("/get-all-position", userHandler.GetAllPosition)
	}
}
