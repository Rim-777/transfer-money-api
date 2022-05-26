require 'rails_helper'

RSpec.describe Account, type: :model do
  it { should belong_to(:user).inverse_of(:accounts) }

  it 'associates to sent_transactions' do
    should have_many(:sent_transactions)
      .class_name('Account::Transaction')
      .inverse_of(:sender)
      .with_foreign_key(:sender_id)
  end

  it 'associates to sent_transactions' do
    should have_many(:received_transactions)
      .class_name('Account::Transaction')
      .inverse_of(:receiver)
      .with_foreign_key(:receiver_id)
  end

  it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
end
