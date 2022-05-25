# frozen_string_literal: true

Dry::Validation.register_macro(:format) do |macro:|
  if value&.!~ macro.args.first
    message = macro.args.second || I18n.t(:invalid_format, scope: 'errors')
    key.failure(message)
  end
end

module Types
  include Dry.Types()
end

