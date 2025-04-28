package helpers

import (
	"fmt"
	"regexp"
	"strings"
)

func StandardizePhoneNumber(phone string) (string, error) {
	re := regexp.MustCompile(`\D`)
	onlyDigits := re.ReplaceAllString(phone, "")

	if strings.HasPrefix(onlyDigits, "0") {
		onlyDigits = "62" + onlyDigits[1:]
	} else if !strings.HasPrefix(onlyDigits, "62") {
		onlyDigits = "62" + onlyDigits
	}

	if len(onlyDigits) < 10 || len(onlyDigits) > 15 {
		return "", fmt.Errorf("invalid phone number length")
	}

	return onlyDigits, nil
}
