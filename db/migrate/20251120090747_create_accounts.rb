class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :platform, null: false # "simpledairy", "purepani", etc
      t.jsonb :metadata, default: {}
      t.timestamps
    end
    add_index :accounts, :platform
  end
end
