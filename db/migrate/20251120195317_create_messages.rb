class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :account, null: false, foreign_key: true
      t.references :template, foreign_key: true
      t.references :user, foreign_key: true
      t.references :customer, foreign_key: true
      t.string :message_group
      t.boolean :bulk_created, default: true
      t.jsonb :payload, default: {}      # Internal structure - Sending message
      t.jsonb :incoming_webhook_payload  # Received from meta as webhook payload
      t.string :status, default: "queued"
      t.string :message_type
      t.string :direction
      t.string :remote_id_meta
      t.jsonb :response_json, default: {}
      t.text :error_text
      t.timestamps
    end
    add_index :messages, :status
  end
end
