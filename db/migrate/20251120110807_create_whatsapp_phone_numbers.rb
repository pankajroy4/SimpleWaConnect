class CreateWhatsappPhoneNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_phone_numbers do |t|
      t.references :account, null: false, foreign_key: true
      t.string :phone_number_id, null: false
      t.string :display_number
      t.integer :status, default: 0, null: false  # enum: 0=active, 1=inactive
      t.string :country_code, default: "91"

      t.timestamps
    end
    add_index :whatsapp_phone_numbers, :phone_number_id, unique: true
    add_index :whatsapp_phone_numbers, :display_number

    add_index :whatsapp_phone_numbers, :account_id, unique: true, where: "status = 0", name: "unique_active_phone_per_account"
  end
end
