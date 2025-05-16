package dto

type (
	PaginationRequest struct {
		QueryParam
		Page    int `form:"page"`
		PerPage int `form:"per_page"`
	}

	QueryParam struct {
		Search string `form:"search"`
	}

	PaginationResponse struct {
		Page    int   `json:"page"`
		PerPage int   `json:"per_page"`
		MaxPage int64 `json:"max_page"`
		Count   int64 `json:"count"`
	}
)

func (p *PaginationRequest) GetOffset() int {
	return (p.Page - 1) * p.PerPage
}

func (pr *PaginationResponse) GetLimit() int {
	return pr.PerPage
}

func (pr *PaginationResponse) GetPage() int {
	return pr.Page
}
