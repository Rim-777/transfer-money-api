# frozen_string_literal: true

module JwtAuthentication
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate_with_jwt!

    def authenticate_with_jwt!
      token = request.headers['Authorization']
      operation = ::Users::Sessions::Read.call(token: token)

      if operation.success?
        @current_user = operation.user
      else
        error_response(operation.errors, :unauthorized)
      end
    end
  end
end
