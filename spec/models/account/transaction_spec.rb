require 'rails_helper'

RSpec.describe Account::Transaction, type: :model do
  it 'associates to sender' do
    should belong_to(:sender)
      .class_name('Account')
      .inverse_of(:sent_transactions)
      .with_foreign_key(:sender_id)
  end

  it 'associates to receiver' do
    should belong_to(:receiver)
      .class_name('Account')
      .inverse_of(:received_transactions)
      .with_foreign_key(:receiver_id)
  end

  it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
end
