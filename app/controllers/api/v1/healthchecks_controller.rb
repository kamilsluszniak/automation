# frozen_string_literal: true

class HealthchecksController < ApplicationController
  def ping
    head :ok
  end
end
