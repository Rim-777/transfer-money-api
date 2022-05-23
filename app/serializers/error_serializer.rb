# frozen_string_literal: true

module ErrorSerializer
  extend self

  def from_messages(error_messages, meta: {})
    error_messages = Array.wrap(error_messages)
    { errors: build_errors(error_messages, meta) }
  end

  alias from_message from_messages

  private

  def build_errors(error_messages, meta)
    error_messages.map { |message| build_error(message, meta) }
  end

  def build_error(message, meta = {})
    error = { detail: message }
    error[:meta] = meta if meta.present?
    error
  end
end
