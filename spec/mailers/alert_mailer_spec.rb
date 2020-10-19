# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertMailer, type: :mailer do
  describe 'alert triggered email' do
    let(:user) { create(:user) }
    let(:alert) { create(:alert, user: user) }
    let(:trigger) { create(:trigger, user: user, alerts: [alert]) }
    let(:mail) { AlertMailer.alert_triggered_email(user, alert) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Alert #{alert.name} was triggered")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['automation@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Hi #{user.name}")
    end
  end
end
