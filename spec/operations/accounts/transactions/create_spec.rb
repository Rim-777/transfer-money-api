# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accounts::Transactions::Create do
  let(:operation) { described_class.new(params) }
  let!(:sender_user) { create(:user) }
  let!(:receiver_user) { create(:user) }
  let(:amount) { 10_000.00 }
  let!(:sender) { create(:account, balance: amount, user: sender_user) }
  let!(:receiver) { create(:account, balance: 0, user: receiver_user) }

  describe '#call' do
    def operation_call
      operation.call
    end

    let(:params) do
      {
        user: sender_user,
        sender_id: sender.id,
        receiver_id: receiver.id,
        amount: amount,
        description: 'For having fun'
      }
    end

    context 'success' do
      it 'looks like success' do
        expect(operation_call).to be_success
      end

      it 'does not contain errors' do
        expect(operation_call.errors).to be_empty
      end

      it 'creates a new transaction' do
        expect { operation_call }.to change(Account::Transaction, :count).from(0).to(1)
      end

      it 'creates a new transaction related to sender' do
        expect { operation_call }.to change(sender.sent_transactions, :count).from(0).to(1)
      end

      it 'creates a new transaction related to receiver' do
        expect { operation_call }.to change(receiver.received_transactions, :count).from(0).to(1)
      end

      it 'sets a transaction as operation transaction' do
        expect(operation_call.transaction).to be_a(Account::Transaction)
      end

      it 'assigns a transaction with expected attributes' do
        expect(operation_call.transaction)
          .to have_attributes(
            sender_id: params.fetch(:sender_id),
            receiver_id: params.fetch(:receiver_id),
            amount: amount,
            description: params.fetch(:description),
            status: 'completed'
          )
      end

      it 'changes balance of a sender' do
        expect do
          operation_call
          sender.reload
        end.to change(sender, :balance).from(amount).to(0)
      end

      it 'changes balance of a sender' do
        expect do
          operation_call
          receiver.reload
        end.to change(receiver, :balance).from(0).to(amount)
      end
    end

    context 'failure' do
      shared_examples :failure do
        it 'looks like failure' do
          expect(operation_call).to be_failure
        end

        it 'contains expected errors' do
          expect(operation_call.errors).to eq(expected_messages)
        end

        it 'does not create transactions' do
          expect do
            operation_call
            receiver.reload
          end.not_to change(Account::Transaction, :count)
        end

        it 'does not change sender balance' do
          expect do
            operation_call
            sender.reload
          end.not_to change(sender, :balance)
        end

        it 'does not change receiver balance' do
          expect do
            operation_call
            receiver.reload
          end.not_to change(receiver, :balance)
        end
      end

      context 'user is not authorized' do
        before do
          params[:user] = create(:user)
        end

        let(:expected_messages) do
          ['User is not allowed to manage the account']
        end

        include_examples :failure
      end

      context 'same account transfer' do
        before do
          params[:receiver_id] = sender.id
        end

        let(:expected_messages) do
          ['Sender and receiver must be different']
        end

        include_examples :failure
      end

      context 'money insufficiency' do
        before do
          sender.update!(balance: 5000)
          sender.reload
        end

        let(:expected_messages) do
          ['Insufficient balance']
        end

        include_examples :failure
      end

      context 'expected AR validation error' do
        before do
          params[:amount] = -100.00
        end

        let(:expected_messages) do
          ['Validation failed: Amount must be greater than or equal to 0']
        end

        include_examples :failure
      end

      context 'unexpected AR validation error' do
        let(:error) {'some error'}

        before do
          sender.errors.add(:base, error)
          allow(operation).to receive(:transfer_amount!).and_raise(ActiveRecord::RecordInvalid.new(sender))
        end

        let(:expected_messages) do
          ["Validation failed: #{error}"]
        end

        include_examples :failure
      end
    end
  end
end
