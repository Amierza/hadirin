package helpers

import (
	"time"
)

var layoutFormat, value string
var date time.Time

func FormatDate(dateReq string) (time.Time, error) {
	layoutFormat := "2006-01-02 15:04:05"
	date, err := time.Parse(layoutFormat, dateReq)
	if err != nil {
		return time.Time{}, err
	}
	return date, nil
}
