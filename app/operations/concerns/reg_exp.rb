# frozen_string_literal: true

module RegExp
  extend ActiveSupport::Concern

  private

  def bearer_token_format
    %r{^Bearer [A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_.+/=]*$}
  end
end
