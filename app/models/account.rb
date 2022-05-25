# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user, inverse_of: :accounts
  has_many :sent_transactions,
           class_name: 'Account::Transaction',
           inverse_of: :sender,
           foreign_key: :sender_id

  has_many :received_transactions,
           class_name: 'Account::Transaction',
           inverse_of: :receiver,
           foreign_key: :receiver_id

  validates :balance, numericality: { greater_than_or_equal_to:  0 }
end
