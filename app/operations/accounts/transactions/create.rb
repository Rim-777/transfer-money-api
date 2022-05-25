module Accounts
  module Transactions
    class Create
      prepend BaseOperation

      option :user, type: Types.Instance(User)
      option :sender_id, type: Dry::Types['strict.integer']
      option :receiver_id, type: Dry::Types['strict.integer']
      option :amount, type: Dry::Types['strict.float']
      option :description, optional: true, type: Dry::Types['strict.string']

      attr_reader :transaction

      def call
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute(<<~SQL).clear
          lock account_transactions in share row exclusive mode;
          SQL
          set_accounts!
          authorize_user
          check_account_identity
          check_sufficiency!
          create_transaction!
          transfer_amount!
          complete!
        rescue ActiveRecord::RecordInvalid => e
          interrupt_with_errors!([e.message])
        end
      end

      private

      def set_accounts!
        @sender = Account.lock.find(@sender_id)
        @receiver = Account.lock.find(@receiver_id)
      end

      def authorize_user
        return if @user == @sender.user
        message = I18n.t(:authorization_error, scope: 'errors', recourse: 'account')
        interrupt_with_errors!([message])
      end

      def check_account_identity
        return unless @sender == @receiver
        message = I18n.t(:same_account_transfer, scope: 'errors')
        interrupt_with_errors!([message])
      end

      def create_transaction!
        @transaction = Account::Transaction.create!(
          sender: @sender,
          receiver: @receiver,
          amount: @amount,
          description: @description
        )
      end

      def check_sufficiency!
        return if @sender.balance >= @amount
        message = I18n.t(:amount_insufficiency, scope: 'errors')
        interrupt_with_errors!([message])
      end

      def transfer_amount!
        sender_new_balance = @sender.balance - @amount
        receiver_new_balance = @receiver.balance + @amount
        @sender.update!(balance: sender_new_balance)
        @receiver.update!(balance: receiver_new_balance)
      end

      def complete!
        @transaction.complete
      end
    end
  end
end