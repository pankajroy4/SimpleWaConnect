# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_25_064206) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "platform", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform"], name: "index_accounts_on_platform"
  end

  create_table "customer_messages", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "message_id"], name: "index_customer_messages_on_customer_id_and_message_id", unique: true
    t.index ["customer_id"], name: "index_customer_messages_on_customer_id"
    t.index ["message_id"], name: "index_customer_messages_on_message_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "phone_number"
    t.string "name"
    t.datetime "last_window_opened_at"
    t.jsonb "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "phone_number"], name: "index_customers_on_account_id_and_phone_number", unique: true
    t.index ["account_id"], name: "index_customers_on_account_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "template_id"
    t.bigint "user_id"
    t.boolean "bulk_created", default: true
    t.jsonb "payload", default: {}
    t.jsonb "incoming_webhook_payload"
    t.string "status", default: "queued"
    t.string "message_type"
    t.string "direction"
    t.string "remote_id"
    t.jsonb "response_json", default: {}
    t.text "error_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_messages_on_account_id"
    t.index ["status"], name: "index_messages_on_status"
    t.index ["template_id"], name: "index_messages_on_template_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "templates", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "language_code", default: "en_US"
    t.boolean "has_header", default: true
    t.string "media_type"
    t.jsonb "header_variables", default: []
    t.jsonb "body_variables", default: []
    t.jsonb "button_variables", default: []
    t.integer "header_var_count", default: 0
    t.integer "body_var_count", default: 0
    t.integer "button_var_count", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name", "language_code"], name: "index_templates_on_account_id_and_name_and_language_code", unique: true
    t.index ["account_id"], name: "index_templates_on_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.bigint "account_id"
    t.string "role"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "whatsapp_credentials", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "access_token"
    t.string "business_id"
    t.string "waba_id"
    t.string "app_id"
    t.string "app_secret"
    t.string "webhook_verify_token"
    t.jsonb "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_whatsapp_credentials_on_account_id"
  end

  create_table "whatsapp_phone_numbers", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "phone_number_id", null: false
    t.string "display_number"
    t.integer "status", default: 0, null: false
    t.string "country_code", default: "91"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_whatsapp_phone_numbers_on_account_id"
    t.index ["account_id"], name: "unique_active_phone_per_account", unique: true, where: "(status = 0)"
    t.index ["display_number"], name: "index_whatsapp_phone_numbers_on_display_number"
    t.index ["phone_number_id"], name: "index_whatsapp_phone_numbers_on_phone_number_id", unique: true
  end

  add_foreign_key "customer_messages", "customers"
  add_foreign_key "customer_messages", "messages"
  add_foreign_key "customers", "accounts"
  add_foreign_key "messages", "accounts"
  add_foreign_key "messages", "templates"
  add_foreign_key "messages", "users"
  add_foreign_key "templates", "accounts"
  add_foreign_key "users", "accounts"
  add_foreign_key "whatsapp_credentials", "accounts"
  add_foreign_key "whatsapp_phone_numbers", "accounts"
end
