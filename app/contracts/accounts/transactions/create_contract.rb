# frozen_string_literal: true

module Accounts
  module Transactions
    class CreateContract < Dry::Validation::Contract
      schema do
        required(:data).hash do
          required(:attributes).hash do
            required(:sender_id).filled(:integer)
            required(:receiver_id).filled(:integer)
            required(:amount).filled(:float)
            optional(:description).maybe(:string)
          end
        end
      end

      rule(%i[data attributes amount]) do
        key.failure(I18n.t(:negative_amount, scope: 'errors')) if value.negative?
      end
    end
  end
end
