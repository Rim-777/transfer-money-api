class CreateAccountTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :account_transactions do |t|
      t.integer :sender_id, foreign_key: true
      t.integer :receiver_id, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :description
      t.string :status, default: 'processing', null: false
      t.index(
        %i[sender_id receiver_id status],
        name: 'indexAccountTransactionsOnSenderIdAndReceiverIdAndStatus'
      )

      t.timestamps
    end
  end
end
