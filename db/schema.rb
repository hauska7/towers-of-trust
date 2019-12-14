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

ActiveRecord::Schema.define(version: 2019_12_13_132945) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id", null: false
    t.bigint "group_id", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["member_id"], name: "index_group_memberships_on_member_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "moderator_id", null: false
    t.index ["moderator_id"], name: "index_groups_on_moderator_id"
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
    t.integer "votes_count", null: false
    t.string "status", null: false
    t.string "color"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.string "status", null: false
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voter_id", null: false
    t.bigint "person_id", null: false
    t.index ["person_id"], name: "index_votes_on_person_id"
    t.index ["voter_id"], name: "index_votes_on_voter_id"
  end

  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users", column: "member_id"
  add_foreign_key "groups", "users", column: "moderator_id"
  add_foreign_key "votes", "users", column: "person_id"
  add_foreign_key "votes", "users", column: "voter_id"
end
