package helpers

import (
	"errors"
	"time"
)

func ParseDate(dateStr string) (*time.Time, error) {
	t, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return nil, errors.New("invalid date format, expected yyyy-mm-dd")
	}
	return &t, nil
}
