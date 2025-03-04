package handler

import (
	"net/http"

	"github.com/Amierza/hadirin/backend/dto"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/Amierza/hadirin/backend/utils"
	"github.com/gin-gonic/gin"
)

type (
	IEmployeeHandler interface {
		Register(ctx *gin.Context)
	}

	EmployeeHandler struct {
		employeeService service.IEmployeeService
	}
)

func NewEmployeeHandler(employeeService service.IEmployeeService) *EmployeeHandler {
	return &EmployeeHandler{
		employeeService: employeeService,
	}
}

func (eh *EmployeeHandler) Register(ctx *gin.Context) {
	var payload dto.EmployeeRegisterRequest
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := eh.employeeService.Register(ctx.Request.Context(), payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_REGISTER_EMPLOYEE, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_REGISTER_EMPLOYEE, result)
	ctx.JSON(http.StatusOK, res)
}
