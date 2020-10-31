# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: %i[create destroy]
  respond_to :json

  def create
    super { |resource| @resource = resource }
  end

  def destroy
    super
  end

  private

  def respond_with(resource, _opts = {})
    render json: UserSerializer.new(resource).serialized_json
  end

  def respond_to_on_destroy
    head :ok
  end
end
