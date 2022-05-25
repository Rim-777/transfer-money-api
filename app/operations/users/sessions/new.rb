# frozen_string_literal: true

module Users
  module Sessions
    class New
      prepend BaseOperation
      include JwtConfig

      EXPIRATION = 600
      option :email, type: Dry::Types['strict.string']
      option :password, type: Dry::Types['strict.string']
      option :issuer, default: -> { 'Transfer Money Api' }, type: Dry::Types['strict.string']

      attr_reader :jwt, :user

      def call
        set_user
        create_jwt!
      end

      private

      def set_user
        ActiveRecord::Base.transaction do
          @user = User.lock.find_by(email: @email)
          return if @user&.valid_password?(@password)
        end

        interrupt_with_errors! [I18n.t(:invalid_email_or_password, scope: 'errors')]
      end

      def create_jwt!
        @jwt = JWT.encode(options, ecdsa_key!, JWT_ALGORITHM)
      end

      def options
        iat = Time.now.utc.to_i
        {
          iss: @issuer,
          sub: @user.id,
          email: @email,
          iat: iat,
          exp: (iat + EXPIRATION)
        }
      end
    end
  end
end
