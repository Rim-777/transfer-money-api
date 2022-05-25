# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :accounts, dependent: :destroy, inverse_of: :user
end
