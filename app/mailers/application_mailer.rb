class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "noreply@mscoast-portal.com")
  layout "mailer"
end
