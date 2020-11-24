# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    respond_to :json
  end
end
