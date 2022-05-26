# frozen_string_literal: true

module JwtConfig
  extend ActiveSupport::Concern

  included do
    def jwt_algorithm
      'ES384'
    end

    def ecdsa_key!
      key = ENV.fetch('JWT_KEY')
      OpenSSL::PKey::EC.new(key)
    end
  end
end
