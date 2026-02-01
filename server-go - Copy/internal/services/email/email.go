package email

import (
	"arfcoder-go/internal/config"
	"fmt"

	"github.com/resend/resend-go/v2"
)

func SendEmail(to, subject, htmlContent string) error {
	client := resend.NewClient(config.ResendAPIKey)

	params := &resend.SendEmailRequest{
		From:    config.EmailFrom,
		To:      []string{to},
		Subject: subject,
		Html:    htmlContent,
	}

	_, err := client.Emails.Send(params)
	if err != nil {
		fmt.Printf("Error sending email: %v\n", err)
		return err
	}

	return nil
}
