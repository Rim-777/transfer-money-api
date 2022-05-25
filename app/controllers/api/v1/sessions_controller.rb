# frozen_string_literal: true

module Api
  module V1
    class SessionsController < BaseController
      before_action :validate_params, only: :create

      def create
        operation = Users::Sessions::New.call(@valid_params[:data][:attributes])
        if operation.success?
          headers['X-AccessToken'] = operation.jwt
          serializer =
            UserSerializer.new(
              operation.user
            )

          render json: serializer.serialized_json, status: :created
        else
          error_response(operation.errors, :unprocessable_entity)
        end
      end

      private

      def auth_params
        params.permit(data: {}).to_h
      end

      def validate_params
        validation = Sessions::CreateContract.new.call(auth_params)
        result_validation(validation)
      end
    end
  end
end
