# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include ApiErrors
      include PaginationLinks
    end
  end
end
