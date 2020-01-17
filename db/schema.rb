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

ActiveRecord::Schema.define(version: 2020_01_17_112004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id", null: false
    t.bigint "group_id", null: false
    t.integer "trust_count", null: false
    t.string "color", null: false
    t.string "status", null: false
    t.bigint "trustee_id"
    t.bigint "tower_id"
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["member_id"], name: "index_group_memberships_on_member_id"
    t.index ["tower_id"], name: "index_group_memberships_on_tower_id"
    t.index ["trustee_id"], name: "index_group_memberships_on_trustee_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "moderator_id", null: false
    t.integer "members_count", null: false
    t.index ["moderator_id"], name: "index_groups_on_moderator_id"
  end

  create_table "towers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id", null: false
    t.bigint "owner_id", null: false
    t.index ["group_id"], name: "index_towers_on_group_id"
    t.index ["owner_id"], name: "index_towers_on_owner_id"
  end

  create_table "trusts", force: :cascade do |t|
    t.string "status", null: false
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id", null: false
    t.bigint "trustee_id", null: false
    t.bigint "truster_id", null: false
    t.index ["group_id"], name: "index_trusts_on_group_id"
    t.index ["trustee_id"], name: "index_trusts_on_trustee_id"
    t.index ["truster_id"], name: "index_trusts_on_truster_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "phone"
    t.datetime "deleted_at"
    t.string "status", null: false
    t.datetime "cancel_account_on"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "group_memberships", "group_memberships", column: "trustee_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "towers"
  add_foreign_key "group_memberships", "users", column: "member_id"
  add_foreign_key "groups", "users", column: "moderator_id"
  add_foreign_key "towers", "group_memberships", column: "owner_id"
  add_foreign_key "towers", "groups"
  add_foreign_key "trusts", "group_memberships", column: "trustee_id"
  add_foreign_key "trusts", "group_memberships", column: "truster_id"
  add_foreign_key "trusts", "groups"
end
