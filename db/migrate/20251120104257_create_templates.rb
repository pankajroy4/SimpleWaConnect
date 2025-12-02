class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :language_code, default: "en_US"
      t.boolean :has_header, default: true
      t.string :media_type  # document, video, image, text

      t.jsonb :header_variables, default: []       # ["date", "otp"]
      t.jsonb :body_variables, default: []         # ["name", "amount", "order_id"]
      # t.jsonb :buttons, default: []              # [{ type: "url", text: "Track", variable: "tracking_code" }]
      t.jsonb :button_variables, default: []

      t.integer :header_var_count, default: 0
      t.integer :body_var_count, default: 0
      t.integer :button_var_count, default: 0
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :templates, [:account_id, :name, :language_code], unique: true
  end
end
