class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.integer :user_id, index: true, foreign_key: true
      t.decimal :balance, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end
  end
end
