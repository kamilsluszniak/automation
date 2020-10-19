# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_19_104034) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.boolean "active", default: false
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "alerts_triggers", id: false, force: :cascade do |t|
    t.bigint "alert_id"
    t.bigint "trigger_id"
    t.index ["alert_id"], name: "index_alerts_triggers_on_alert_id"
    t.index ["trigger_id"], name: "index_alerts_triggers_on_trigger_id"
  end

  create_table "charts", force: :cascade do |t|
    t.string "name"
    t.string "metric"
    t.integer "default_duration"
    t.string "default_duration_unit"
    t.bigint "user_id"
    t.bigint "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_charts_on_device_id"
    t.index ["name"], name: "index_charts_on_name", unique: true
    t.index ["user_id"], name: "index_charts_on_user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.text "authentication_token"
    t.datetime "authentication_token_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.integer "turn_on_time"
    t.integer "turn_off_time"
    t.string "intensity"
    t.integer "on_temperature"
    t.integer "off_temperature"
    t.integer "on_volume"
    t.integer "off_volume"
    t.string "group"
    t.decimal "temperature_set"
    t.string "status"
    t.boolean "on"
    t.string "slug"
    t.decimal "distance"
    t.string "intensity_override"
    t.integer "co2valve_on_time"
    t.integer "co2valve_off_time"
    t.float "light_intensity_lvl"
    t.boolean "water_input_valve_on", default: false
    t.bigint "user_id"
    t.string "connected_devices"
    t.index ["authentication_token"], name: "index_devices_on_authentication_token", unique: true
    t.index ["name"], name: "index_devices_on_name", unique: true
    t.index ["reset_password_token"], name: "index_devices_on_reset_password_token", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "triggers", force: :cascade do |t|
    t.string "name"
    t.string "conditions"
    t.string "type"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_triggers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "authentication_token"
    t.datetime "authentication_token_created_at"
    t.string "name"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "alerts", "users"
  add_foreign_key "alerts_triggers", "alerts"
  add_foreign_key "alerts_triggers", "triggers"
  add_foreign_key "charts", "devices"
  add_foreign_key "charts", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "triggers", "users"
end
