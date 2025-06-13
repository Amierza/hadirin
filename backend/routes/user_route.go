package routes

import (
	"github.com/Amierza/hadirin/backend/handler"
	"github.com/Amierza/hadirin/backend/middleware"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/gin-gonic/gin"
)

func User(route *gin.Engine, userHandler handler.IUserHandler, jwtService service.IJWTService) {
	routes := route.Group("/api/v1/user")
	{
		// Authentication
		routes.POST("/register", userHandler.Register)
		routes.POST("/login", userHandler.Login)
		routes.POST("/refresh-token", userHandler.RefreshToken)

		// Position
		routes.GET("/get-all-position", userHandler.GetAllPosition)

		routes.Use(middleware.Authentication(jwtService), middleware.RouteAccessControl(jwtService))
		{
			// User
			routes.GET("/get-detail-user", userHandler.GetDetailUser)
			routes.PATCH("/update-user", userHandler.UpdateUser)

			// Attendance
			routes.POST("/create-attendance", userHandler.CreateAttendace)
			routes.PATCH("/update-attendance/:id", userHandler.UpdateAttendaceOut)

			// Permit
			routes.POST("/create-permit", userHandler.CreatePermit)
			routes.GET("/get-all-permit", userHandler.GetAllPermit)
			routes.GET("/get-detail-permit/:id", userHandler.GetDetailPermit)
			routes.PATCH("/update-permit/:id", userHandler.UpdatePermit)
			routes.DELETE("/delete-permit/:id", userHandler.DeletePermit)
		}
	}
}
