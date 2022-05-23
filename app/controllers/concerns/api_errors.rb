# frozen_string_literal: true

module ApiErrors
  extend ActiveSupport::Concern

  included do
    rescue_from(StandardError) { |e| handle_unexpected_exception(e) }
  end

  private

  def handle_unexpected_exception(e)
    case e
    when ActiveRecord::RecordNotFound
      error_response(e.message, :not_found)
    else
      error_response(I18n.t(:unhandled, scope: 'api.errors'), :unprocessable_entity)
    end
  end

  def error_response(error_messages, status)
    render json: ErrorSerializer.from_messages(error_messages), status: status
  end
end
