package email

import (
	"arfcoder-go/internal/config"
	"fmt"
	"strings"

	"github.com/resend/resend-go/v2"
)

func GenerateOtpEmail(name, code, title string) string {
	template := `
	<!DOCTYPE html>
	<html>
	<head>
		<style>
			body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }
			.container { max-width: 600px; margin: 20px auto; background: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
			.header { text-align: center; padding-bottom: 20px; border-bottom: 1px solid #eee; }
			.header h1 { color: #333; }
			.content { padding: 20px 0; text-align: center; }
			.otp-box { background: #f8f9fa; padding: 15px; border-radius: 5px; font-size: 24px; font-weight: bold; letter-spacing: 5px; color: #0070f3; margin: 20px 0; display: inline-block; border: 1px dashed #0070f3; }
			.footer { text-align: center; font-size: 12px; color: #888; margin-top: 20px; border-top: 1px solid #eee; padding-top: 10px; }
		</style>
	</head>
	<body>
		<div class="container">
			<div class="header">
				<h1>{{TITLE}}</h1>
			</div>
			<div class="content">
				<p>Halo <strong>{{NAME}}</strong>,</p>
				<p>Gunakan kode verifikasi berikut untuk melanjutkan:</p>
				<div class="otp-box">{{CODE}}</div>
				<p>Kode ini akan kadaluarsa dalam 5 menit.</p>
				<p>Jika Anda tidak meminta kode ini, abaikan email ini.</p>
			</div>
			<div class="footer">
				<p>&copy; 2026 ArfCoder. All rights reserved.</p>
			</div>
		</div>
	</body>
	</html>
	`
	template = strings.ReplaceAll(template, "{{TITLE}}", title)
	template = strings.ReplaceAll(template, "{{NAME}}", name)
	template = strings.ReplaceAll(template, "{{CODE}}", code)
	return template
}

func GenerateLinkEmail(name, link, title, buttonText string) string {
	template := `
	<!DOCTYPE html>
	<html>
	<head>
		<style>
			body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }
			.container { max-width: 600px; margin: 20px auto; background: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
			.header { text-align: center; padding-bottom: 20px; border-bottom: 1px solid #eee; }
			.header h1 { color: #333; }
			.content { padding: 20px 0; text-align: center; }
			.btn { background: #000; color: #fff; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block; margin: 20px 0; }
			.footer { text-align: center; font-size: 12px; color: #888; margin-top: 20px; border-top: 1px solid #eee; padding-top: 10px; }
		</style>
	</head>
	<body>
		<div class="container">
			<div class="header">
				<h1>{{TITLE}}</h1>
			</div>
			<div class="content">
				<p>Halo <strong>{{NAME}}</strong>,</p>
				<p>Klik tombol di bawah untuk melanjutkan:</p>
				<a href="{{LINK}}" class="btn">{{BUTTON}}</a>
				<p>Link ini akan kadaluarsa dalam 1 jam.</p>
				<p>Jika tombol tidak berfungsi, copy link ini:</p>
				<p style="word-break: break-all; color: #0070f3; font-size: 12px;">{{LINK}}</p>
			</div>
			<div class="footer">
				<p>&copy; 2026 ArfCoder. All rights reserved.</p>
			</div>
		</div>
	</body>
	</html>
	`
	template = strings.ReplaceAll(template, "{{TITLE}}", title)
	template = strings.ReplaceAll(template, "{{NAME}}", name)
	template = strings.ReplaceAll(template, "{{LINK}}", link)
	template = strings.ReplaceAll(template, "{{BUTTON}}", buttonText)
	return template
}

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
