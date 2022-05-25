module Api
  module V1
    module Accounts
      class TransactionsController < BaseController
        include JwtAuthentication
        include ApiValidations

        before_action :validate_params, only: :create

        def create
          operation = ::Accounts::Transactions::Create.call(
            user: current_user, **@valid_params[:data][:attributes]
          )

          if operation.success?
            serializer =
              ::Accounts::TransactionSerializer.new(
                operation.transaction,
                include: %w[
                  sender.user
                  receiver.user
                ]
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
          validation = ::Accounts::Transactions::CreateContract.new.call(auth_params)
          result_validation(validation)
        end
      end
    end
  end
end
