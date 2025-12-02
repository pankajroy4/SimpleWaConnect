class CreateWhatsappCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_credentials do |t|
      t.references :account, null: false, foreign_key: true
      t.text :access_token
      t.string :business_id
      t.string :waba_id
      t.string :app_id
      t.string :app_secret
      t.string :webhook_verify_token
      t.jsonb :meta, default: {}
      t.timestamps
    end
  end
end
