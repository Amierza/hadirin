package dto

type (
	PaginationRequest struct {
		Search  string `form:"search"`
		Page    int    `form:"page"`
		PerPage int    `form:"per_page"`
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
