# frozen_string_literal: true

class AlertMailer < ApplicationMailer
  def alert_triggered_email(user, alert)
    @user = user
    @alert = alert
    mail(to: @user.email, subject: "Alert #{alert.name} was triggered")
  end
end
