# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160815122450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airports", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.string   "name_unsigned"
    t.string   "short_name"
    t.boolean  "is_domestic"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "alerts", force: :cascade do |t|
    t.string   "email"
    t.string   "name"
    t.integer  "ori_air_id"
    t.integer  "des_air_id"
    t.datetime "time_start"
    t.decimal  "price_expect"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "status"
    t.string   "token"
  end

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",            null: false
    t.text     "log"
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true, using: :btree
  end

  create_table "flights", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "category"
    t.integer  "plane_category_id"
    t.datetime "time_depart"
    t.datetime "time_arrive"
    t.string   "code_flight"
    t.string   "code_book"
    t.decimal  "price_web"
    t.decimal  "price_total"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["order_id"], name: "index_flights_on_order_id", using: :btree
    t.index ["plane_category_id"], name: "index_flights_on_plane_category_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.string   "order_number"
    t.integer  "user_id"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.string   "contact_gender"
    t.integer  "adult"
    t.integer  "child"
    t.integer  "infant"
    t.integer  "ori_airport_id"
    t.integer  "des_airport_id"
    t.string   "status"
    t.datetime "time_expired"
    t.decimal  "price_total"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "category"
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "passengers", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "no"
    t.datetime "dob"
    t.string   "category"
    t.integer  "depart_lug_weight"
    t.integer  "return_lug_weight"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["order_id"], name: "index_passengers_on_order_id", using: :btree
  end

  create_table "plane_categories", force: :cascade do |t|
    t.string   "category"
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routes", force: :cascade do |t|
    t.integer  "ori_airport_id"
    t.integer  "des_airport_id"
    t.boolean  "is_domestic"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "phone"
    t.string   "gender"
    t.boolean  "is_admin"
    t.boolean  "is_registered"
    t.string   "confirmation_token"
    t.string   "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "flights", "orders"
  add_foreign_key "flights", "plane_categories"
  add_foreign_key "orders", "users"
  add_foreign_key "passengers", "orders"
end
