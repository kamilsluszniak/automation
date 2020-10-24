# frozen_string_literal: true

class CreateUser
  include Wisper::Publisher

  def call(sign_up_params)
    user = User.new(sign_up_params)
    if user.save
      broadcast(:create_user_success, user)
    else
      broadcast(:create_user_failed, user)
    end
  end
end
