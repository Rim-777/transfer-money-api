# frozen_string_literal: true

module JwtConfig
  extend ActiveSupport::Concern
  JWT_ALGORITHM = 'ES384'

  included do
    def ecdsa_key!
      key = ENV.fetch('JWT_KEY')
      OpenSSL::PKey::EC.new(key)
    end
  end
end
