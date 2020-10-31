# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    # include ActionController::ImplicitRender
    respond_to :json
  end
end
