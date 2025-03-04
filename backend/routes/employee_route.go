package routes

import (
	"github.com/Amierza/hadirin/backend/handler"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/gin-gonic/gin"
)

func Employee(route *gin.Engine, employeeHandler handler.IEmployeeHandler, jwtService service.IJWTService) {
	routes := route.Group("/api/v1/employee")
	{
		routes.POST("/register", employeeHandler.Register)
	}
}
