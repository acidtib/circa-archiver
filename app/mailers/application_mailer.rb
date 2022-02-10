class ApplicationMailer < ActionMailer::Base
  default from: "hello@#{ENV["SMTP_DOMAIN"]}"
  layout "mailer"
end
