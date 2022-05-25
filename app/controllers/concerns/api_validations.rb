# frozen_string_literal: true

module ApiValidations
  extend ActiveSupport::Concern

  private

  def result_validation(validation)
    if validation.success?
      @valid_params = validation.to_h
    else
      message = validation.errors.to_h
      error_response(message, :bad_request)
    end
  end
end
