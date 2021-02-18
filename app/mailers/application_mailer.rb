# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'easyautomateme@no-reply.com'
  layout 'mailer'
end
