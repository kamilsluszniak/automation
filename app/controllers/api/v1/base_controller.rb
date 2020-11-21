# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      # include ActionController::ImplicitRender
      respond_to :json
    end
  end
end
