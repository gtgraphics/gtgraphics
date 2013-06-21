# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130621212541) do

  create_table "images", force: true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", force: true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
  end

  add_index "pages", ["path"], name: "index_pages_on_path", unique: true, using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree

  create_table "portfolios", force: true do |t|
    t.string   "owner_name"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  add_index "portfolios", ["slug"], name: "index_portfolios_on_slug", unique: true, using: :btree

  create_table "redirections", force: true do |t|
    t.string   "source_path"
    t.string   "destination_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redirections", ["source_path"], name: "index_redirections_on_source_path", unique: true, using: :btree

  create_table "testimonials", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.date     "launched_on"
    t.string   "client_name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "testimonials", ["slug"], name: "index_testimonials_on_slug", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "slug"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

end
