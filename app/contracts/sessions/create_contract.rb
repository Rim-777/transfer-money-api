# frozen_string_literal: true

module Sessions
  class CreateContract < Dry::Validation::Contract
    EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    schema do
      required(:data).hash do
        required(:attributes).hash do
          required(:email).filled(:string)
          required(:password).filled(:string)
        end
      end
    end

    rule(%i[data attributes email]).validate(format: EMAIL_FORMAT)

    rule(%i[data attributes password]) do
      key.failure(I18n.t(:invalid_password, scope: 'errors')) if value.size <= 6
    end
  end
end
