# frozen_string_literal: true

module Users
  module Sessions
    class Read
      prepend BaseOperation
      include JwtConfig
      include RegExp

      option :token, type: Dry::Types['strict.string']
      attr_reader :user

      def call
        validate_format
        decode!
        set_user!
      end

      private

      def validate_format
        return if @token&.match?(bearer_token_format)

        interrupt_with_invalid_token
      end

      def decode!
        options = { verify_expiration: true, algorithm: jwt_algorithm }
        encoded_jwt = @token.split(' ').last
        @decoded_jwt = JWT.decode(encoded_jwt, ecdsa_key!, true, options)
      rescue JWT::ExpiredSignature
        interrupt_with_errors!([I18n.t(:expired_access_token, scope: 'errors')])
      rescue JWT::DecodeError
        interrupt_with_invalid_token
      end

      def set_user!
        user_id = @decoded_jwt.first.fetch('sub')
        @user = User.find(user_id)
      rescue ActiveRecord::RecordNotFound
        fail!(invalid_token_message)
      end

      def invalid_token_message
        [I18n.t(:invalid_access_token, scope: 'errors')]
      end

      def interrupt_with_invalid_token
        interrupt_with_errors!(invalid_token_message)
      end
    end
  end
end
