class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.references :account, null: false, foreign_key: true
      t.string :phone_number
      t.string :name
      t.boolean :bulk_created, default: true
      t.datetime :last_window_opened_at
      t.jsonb :profile

      t.timestamps
    end
    add_index :customers, [:account_id, :phone_number], unique: true
  end
end
