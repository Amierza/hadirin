package handler

import (
	"net/http"

	"github.com/Amierza/hadirin/backend/dto"
	"github.com/Amierza/hadirin/backend/service"
	"github.com/Amierza/hadirin/backend/utils"
	"github.com/gin-gonic/gin"
)

type (
	IUserHandler interface {
		// Authentication
		Register(ctx *gin.Context)
		Login(ctx *gin.Context)
		RefreshToken(ctx *gin.Context)

		// Position
		GetAllPosition(ctx *gin.Context)

		// User
		GetDetailUser(ctx *gin.Context)
		UpdateUser(ctx *gin.Context)

		// Presence
		CreateAttendace(ctx *gin.Context)

		// Permit
		CreatePermit(ctx *gin.Context)
		GetAllPermit(ctx *gin.Context)
		GetDetailPermit(ctx *gin.Context)
		UpdatePermit(ctx *gin.Context)
		DeletePermit(ctx *gin.Context)
	}

	UserHandler struct {
		userService service.IUserService
	}
)

func NewUserHandler(userService service.IUserService) *UserHandler {
	return &UserHandler{
		userService: userService,
	}
}

// Authentication
func (eh *UserHandler) Register(ctx *gin.Context) {
	var payload dto.UserRegisterRequest
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := eh.userService.Register(ctx.Request.Context(), payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_REGISTER_USER, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_REGISTER_USER, result)
	ctx.JSON(http.StatusOK, res)
}
func (uh *UserHandler) Login(ctx *gin.Context) {
	var payload dto.UserLoginRequest
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := uh.userService.Login(ctx.Request.Context(), payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_LOGIN_USER, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_LOGIN_USER, result)
	ctx.JSON(http.StatusOK, res)
}
func (uh *UserHandler) RefreshToken(ctx *gin.Context) {
	var payload dto.RefreshTokenRequest
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := uh.userService.RefreshToken(ctx, payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_REFRESH_TOKEN, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_REFRESH_TOKEN, result)
	ctx.AbortWithStatusJSON(http.StatusOK, res)
}

// Position
func (uh *UserHandler) GetAllPosition(ctx *gin.Context) {
	result, err := uh.userService.GetAllPosition(ctx.Request.Context())
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_LIST_POSITION, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.Response{
		Status:   true,
		Messsage: dto.MESSAGE_SUCCESS_GET_LIST_POSITION,
		Data:     result.Data,
	}

	ctx.JSON(http.StatusOK, res)
}

// User
func (uh *UserHandler) GetDetailUser(ctx *gin.Context) {
	result, err := uh.userService.GetDetailUser(ctx)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DETAIL_USER, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_GET_DETAIL_USER, result)
	ctx.JSON(http.StatusOK, res)
}
func (uh *UserHandler) UpdateUser(ctx *gin.Context) {
	var payload dto.UpdateUserRequest
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := uh.userService.UpdateUser(ctx, payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_UPDATE_USER, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_UPDATE_USER, result)
	ctx.JSON(http.StatusOK, res)
}

// Preseence
func (uh *UserHandler) CreateAttendace(ctx *gin.Context) {
	latitude := ctx.PostForm("att_latitude_in")
	longitude := ctx.PostForm("att_longitude_in")
	dateInStr := ctx.PostForm("att_date_in")

	fileHeader, err := ctx.FormFile("att_photo_in")
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_READ_PHOTO, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusInternalServerError, res)
		return
	}

	file, err := fileHeader.Open()
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_OPEN_PHOTO, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusInternalServerError, res)
		return
	}
	defer file.Close()

	payload := dto.CreateAttendanceInRequest{
		DateIn:      dateInStr,
		LatitudeIn:  latitude,
		LongitudeIn: longitude,
		FileHeader:  fileHeader,
		FileReader:  file,
	}

	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := uh.userService.CreateAttendance(ctx, payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_CREATE_ATTENDANCE, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_CREATE_ATTENDANCE, result)
	ctx.JSON(http.StatusOK, res)
}

// Permit
func (uh *UserHandler) CreatePermit(ctx *gin.Context) {
	var payload dto.PermitRequest
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := uh.userService.CreatePermit(ctx, payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_CREATE_PERMIT, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_CREATE_PERMIT, result)
	ctx.JSON(http.StatusOK, res)
}
func (uh *UserHandler) GetAllPermit(ctx *gin.Context) {
	var payload dto.PermitMonthRequest
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := uh.userService.GetAllPermit(ctx, payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_LIST_PERMIT, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_GET_LIST_PERMIT, result)
	ctx.JSON(http.StatusOK, res)
}
func (uh *UserHandler) GetDetailPermit(ctx *gin.Context) {
	idStr := ctx.Param("id")
	result, err := uh.userService.GetDetailPermit(ctx, idStr)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DETAIL_PERMIT, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_GET_DETAIL_PERMIT, result)
	ctx.JSON(http.StatusOK, res)
}
func (uh *UserHandler) UpdatePermit(ctx *gin.Context) {
	idStr := ctx.Param("id")
	var payload dto.PermitRequest
	payload.ID = idStr
	if err := ctx.ShouldBind(&payload); err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_GET_DATA_FROM_BODY, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	result, err := uh.userService.UpdatePermit(ctx, payload)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_UPDATE_PERMIT, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_UPDATE_PERMIT, result)
	ctx.JSON(http.StatusOK, res)
}
func (uh *UserHandler) DeletePermit(ctx *gin.Context) {
	idStr := ctx.Param("id")
	result, err := uh.userService.DeletePermit(ctx, idStr)
	if err != nil {
		res := utils.BuildResponseFailed(dto.MESSAGE_FAILED_DELETE_PERMIT, err.Error(), nil)
		ctx.AbortWithStatusJSON(http.StatusBadRequest, res)
		return
	}

	res := utils.BuildResponseSuccess(dto.MESSAGE_SUCCESS_DELETE_PERMIT, result)
	ctx.JSON(http.StatusOK, res)
}
