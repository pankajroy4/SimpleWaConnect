class CreateCustomerMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :customer_messages do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :message, null: false, foreign_key: true

      t.timestamps
    end
    add_index :customer_messages, [:customer_id, :message_id], unique: true
  end
end
