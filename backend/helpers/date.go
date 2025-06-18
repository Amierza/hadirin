package helpers

import (
	"fmt"
	"time"
)

var layoutFormat, value string
var date time.Time

func FormatDate(dateReq string) (time.Time, error) {
	layoutFormat := "2006-01-02 15:04:05"
	loc, _ := time.LoadLocation("Asia/Jakarta")
	date, err := time.ParseInLocation(layoutFormat, dateReq, loc)
	if err != nil {
		return time.Time{}, err
	}
	return date, nil
}

func ParseDateOnly(dateStr string) (time.Time, error) {
	const layout = "2006-01-02"
	loc, _ := time.LoadLocation("Asia/Jakarta")

	parsedDate, err := time.ParseInLocation(layout, dateStr, loc)
	if err != nil {
		return time.Time{}, fmt.Errorf("invalid date format: %w", err)
	}

	return parsedDate, nil
}
