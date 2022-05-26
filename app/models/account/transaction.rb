# frozen_string_literal: true

class Account::Transaction < ApplicationRecord
  belongs_to :sender,
             class_name: 'Account',
             foreign_key: :sender_id,
             inverse_of: :sent_transactions

  belongs_to :receiver,
             class_name: 'Account',
             foreign_key: :receiver_id,
             inverse_of: :received_transactions

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  state_machine :status, initial: :processing do
    event :complete do
      transition all => :completed
    end
  end
end
