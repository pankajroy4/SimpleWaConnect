class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :language_code, default: "en_US"
      t.boolean :has_header, default: true
      t.string :media_type  # document, video, image, text/nil

      t.jsonb :header_variables, default: []       # ["date", "otp"]
      t.jsonb :body_variables, default: []         # ["name", "amount", "order_id"]
      t.jsonb :button_variables, default: []       #[tracking_code]
      t.jsonb :buttons, default: []   #[{type: "quick_reply"}, { type: "url", variable: "tracking_code" }]

      t.boolean :active, default: true
      t.timestamps
    end
    add_index :templates, [:account_id, :name, :language_code], unique: true
  end
end
