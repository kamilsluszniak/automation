# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'automation@example.com'
  layout 'mailer'
end
