package utils

type Response struct {
	Status   bool   `json:"status"`
	Messsage string `json:"message"`
	Data     any    `json:"data,omitempty"`
	Error    any    `json:"error,omitempty"`
	Meta     any    `json:"meta,omitempty"`
}

func BuildResponseSuccess(message string, data any) Response {
	res := Response{
		Status:   true,
		Messsage: message,
		Data:     data,
	}

	return res
}

func BuildResponseFailed(message string, err string, data any) Response {
	res := Response{
		Status:   false,
		Messsage: message,
		Error:    err,
		Data:     data,
	}

	return res
}
