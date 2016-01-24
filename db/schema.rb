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

ActiveRecord::Schema.define(version: 20160124173727) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachment_translations", force: :cascade do |t|
    t.integer  "attachment_id", null: false
    t.string   "locale",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "title"
    t.text     "description"
  end

  add_index "attachment_translations", ["attachment_id", "locale"], name: "index_attachment_translations_on_foreign_id_and_locale", unique: true, using: :btree
  add_index "attachment_translations", ["attachment_id"], name: "index_attachment_translations_on_attachment_id", using: :btree
  add_index "attachment_translations", ["locale"], name: "index_attachment_translations_on_locale", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "asset"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "asset_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.string   "original_filename"
    t.string   "asset_token",                   null: false
    t.integer  "downloads_count",   default: 0, null: false
  end

  add_index "attachments", ["author_id"], name: "index_attachments_on_author_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "country",     limit: 2
    t.string "website_url"
  end

  add_index "clients", ["name"], name: "index_clients_on_name", unique: true, using: :btree

  create_table "contact_form_pages", force: :cascade do |t|
    t.integer "template_id"
  end

  add_index "contact_form_pages", ["template_id"], name: "index_contact_form_pages_on_template_id", using: :btree

  create_table "contact_form_recipients", id: false, force: :cascade do |t|
    t.integer "contact_form_page_id"
    t.integer "recipient_id"
  end

  add_index "contact_form_recipients", ["contact_form_page_id", "recipient_id"], name: "index_cfr_on_contact_form_id_and_recipient_id", using: :btree
  add_index "contact_form_recipients", ["recipient_id", "contact_form_page_id"], name: "index_cfr_on_recipient_id_and_contact_form_id", using: :btree

  create_table "content_pages", force: :cascade do |t|
    t.integer "template_id"
  end

  add_index "content_pages", ["template_id"], name: "index_content_pages_on_template_id", using: :btree

  create_table "hits", force: :cascade do |t|
    t.integer  "hittable_id",              null: false
    t.string   "hittable_type",            null: false
    t.datetime "created_at",               null: false
    t.string   "referer"
    t.string   "user_agent"
    t.string   "type"
    t.string   "ip",            limit: 11
  end

  add_index "hits", ["hittable_type", "hittable_id"], name: "index_hits_on_hittable_type_and_hittable_id", using: :btree
  add_index "hits", ["type"], name: "index_hits_on_type", using: :btree

  create_table "homepage_pages", force: :cascade do |t|
    t.integer "template_id"
  end

  add_index "homepage_pages", ["template_id"], name: "index_homepage_pages_on_template_id", using: :btree

  create_table "image_attachments", force: :cascade do |t|
    t.integer "image_id"
    t.integer "attachment_id"
    t.integer "position",      null: false
  end

  add_index "image_attachments", ["attachment_id"], name: "index_image_attachments_on_attachment_id", using: :btree
  add_index "image_attachments", ["image_id"], name: "index_image_attachments_on_image_id", using: :btree

  create_table "image_pages", force: :cascade do |t|
    t.integer "template_id"
    t.integer "image_id",    null: false
  end

  add_index "image_pages", ["image_id"], name: "index_image_pages_on_image_id", using: :btree
  add_index "image_pages", ["template_id"], name: "index_image_pages_on_template_id", using: :btree

  create_table "image_style_translations", force: :cascade do |t|
    t.integer  "image_style_id", null: false
    t.string   "locale",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "title"
  end

  add_index "image_style_translations", ["image_style_id"], name: "index_image_style_translations_on_image_style_id", using: :btree
  add_index "image_style_translations", ["locale"], name: "index_image_style_translations_on_locale", using: :btree

  create_table "image_styles", force: :cascade do |t|
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "asset_updated_at"
    t.integer  "original_width"
    t.integer  "original_height"
    t.text     "customization_options"
    t.integer  "width"
    t.integer  "height"
    t.string   "original_filename"
    t.string   "asset_token",                       null: false
    t.integer  "downloads_count",       default: 0, null: false
    t.integer  "position",                          null: false
  end

  add_index "image_styles", ["asset_token"], name: "index_image_styles_on_asset_token", using: :btree
  add_index "image_styles", ["image_id", "asset_token"], name: "index_image_styles_on_image_id_and_asset_token", unique: true, using: :btree
  add_index "image_styles", ["image_id"], name: "index_image_styles_on_image_id", using: :btree

  create_table "image_translations", force: :cascade do |t|
    t.integer  "image_id",    null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "title"
    t.text     "description"
  end

  add_index "image_translations", ["image_id", "locale"], name: "index_image_translations_on_foreign_id_and_locale", unique: true, using: :btree
  add_index "image_translations", ["image_id"], name: "index_image_translations_on_image_id", using: :btree
  add_index "image_translations", ["locale"], name: "index_image_translations_on_locale", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "asset"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "asset_updated_at"
    t.integer  "original_width"
    t.integer  "original_height"
    t.text     "exif_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.text     "customization_options"
    t.integer  "width"
    t.integer  "height"
    t.string   "original_filename"
    t.string   "asset_token",           null: false
    t.text     "shop_urls"
  end

  add_index "images", ["asset_token"], name: "index_images_on_asset_token", unique: true, using: :btree
  add_index "images", ["author_id"], name: "index_images_on_author_id", using: :btree

  create_table "message_recipiences", force: :cascade do |t|
    t.integer "message_id"
    t.integer "recipient_id"
    t.boolean "read",         default: false, null: false
  end

  add_index "message_recipiences", ["message_id"], name: "index_message_recipiences_on_message_id", using: :btree
  add_index "message_recipiences", ["recipient_id"], name: "index_message_recipiences_on_recipient_id", using: :btree

  create_table "message_sender_infos", force: :cascade do |t|
    t.string   "ip",         limit: 11
    t.datetime "created_at"
  end

  add_index "message_sender_infos", ["created_at"], name: "index_message_sender_infos_on_created_at", using: :btree
  add_index "message_sender_infos", ["ip"], name: "index_message_sender_infos_on_ip", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "first_sender_name"
    t.string   "last_sender_name"
    t.string   "sender_email"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.integer  "delegator_id"
    t.string   "type",              null: false
    t.string   "ip"
  end

  add_index "messages", ["type"], name: "index_messages_on_type", using: :btree

  create_table "page_region_translations", force: :cascade do |t|
    t.integer  "page_region_id", null: false
    t.string   "locale",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "body"
  end

  add_index "page_region_translations", ["locale"], name: "index_page_region_translations_on_locale", using: :btree
  add_index "page_region_translations", ["page_region_id"], name: "index_page_region_translations_on_page_region_id", using: :btree

  create_table "page_regions", force: :cascade do |t|
    t.integer  "definition_id"
    t.integer  "page_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_regions", ["definition_id"], name: "index_page_regions_on_definition_id", using: :btree
  add_index "page_regions", ["page_id"], name: "index_page_regions_on_page_id", using: :btree

  create_table "page_translations", force: :cascade do |t|
    t.integer  "page_id",          null: false
    t.string   "locale",           null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "title"
    t.text     "meta_description"
    t.text     "meta_keywords"
  end

  add_index "page_translations", ["locale"], name: "index_page_translations_on_locale", using: :btree
  add_index "page_translations", ["page_id", "locale"], name: "index_page_translations_on_foreign_id_and_locale", unique: true, using: :btree
  add_index "page_translations", ["page_id"], name: "index_page_translations_on_page_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "slug"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.integer  "embeddable_id"
    t.string   "embeddable_type"
    t.boolean  "menu_item",                 default: true, null: false
    t.boolean  "indexable",                 default: true, null: false
    t.integer  "children_count",            default: 0,    null: false
    t.boolean  "published",                 default: true, null: false
    t.integer  "hits_count",                default: 0,    null: false
    t.string   "permalink",       limit: 6,                null: false
    t.text     "metadata"
  end

  add_index "pages", ["depth"], name: "index_pages_on_depth", using: :btree
  add_index "pages", ["embeddable_type", "embeddable_id"], name: "index_pages_on_embeddable_type_and_embeddable_id", using: :btree
  add_index "pages", ["lft"], name: "index_pages_on_lft", using: :btree
  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["path", "embeddable_type"], name: "index_pages_on_path_and_embeddable_type", using: :btree
  add_index "pages", ["path"], name: "index_pages_on_path", unique: true, using: :btree
  add_index "pages", ["permalink"], name: "index_pages_on_permalink", unique: true, using: :btree
  add_index "pages", ["rgt"], name: "index_pages_on_rgt", using: :btree

  create_table "project_images", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "image_id"
    t.integer  "position",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_images", ["image_id"], name: "index_project_images_on_image_id", using: :btree
  add_index "project_images", ["project_id"], name: "index_project_images_on_project_id", using: :btree

  create_table "project_pages", force: :cascade do |t|
    t.integer "template_id"
    t.integer "project_id",  null: false
  end

  add_index "project_pages", ["project_id"], name: "index_project_pages_on_project_id", using: :btree
  add_index "project_pages", ["template_id"], name: "index_project_pages_on_template_id", using: :btree

  create_table "project_translations", force: :cascade do |t|
    t.integer  "project_id",           null: false
    t.string   "locale",               null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.string   "project_translations"
    t.string   "project_type"
  end

  add_index "project_translations", ["locale"], name: "index_project_translations_on_locale", using: :btree
  add_index "project_translations", ["project_id"], name: "index_project_translations_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "author_id"
    t.integer  "released_in"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "images_count", default: 0, null: false
  end

  add_index "projects", ["author_id"], name: "index_projects_on_author_id", using: :btree
  add_index "projects", ["client_id"], name: "index_projects_on_client_id", using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.string   "logo"
    t.datetime "logo_updated_at"
    t.string   "asset_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "redirection_pages", force: :cascade do |t|
    t.boolean "external",            default: false, null: false
    t.integer "destination_page_id"
    t.string  "destination_url"
    t.boolean "permanent",           default: false, null: false
  end

  add_index "redirection_pages", ["destination_page_id"], name: "index_redirection_pages_on_destination_page_id", using: :btree

  create_table "shouts", force: :cascade do |t|
    t.string   "nickname"
    t.text     "message"
    t.integer  "x",          null: false
    t.integer  "y",          null: false
    t.string   "ip"
    t.string   "user_agent"
    t.datetime "created_at"
    t.integer  "star_type"
  end

  create_table "snippets", force: :cascade do |t|
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "snippets", ["author_id"], name: "index_snippets_on_author_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id",        null: false
    t.integer "taggable_id",   null: false
    t.string  "taggable_type", null: false
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "label", null: false
  end

  add_index "tags", ["label"], name: "index_tags_on_label", unique: true, using: :btree

  create_table "template_region_definitions", force: :cascade do |t|
    t.integer  "template_id"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "position",                     null: false
    t.string   "region_type", default: "full"
  end

  add_index "template_region_definitions", ["label"], name: "index_template_region_definitions_on_label", using: :btree
  add_index "template_region_definitions", ["template_id", "label"], name: "index_template_region_definitions_on_template_id_and_label", unique: true, using: :btree
  add_index "template_region_definitions", ["template_id"], name: "index_template_region_definitions_on_template_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "file_name"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.integer  "position",    null: false
  end

  create_table "user_social_links", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "provider_id"
    t.string   "url"
    t.boolean  "shop",        default: false, null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_social_links", ["provider_id"], name: "index_user_social_links_on_provider_id", using: :btree
  add_index "user_social_links", ["user_id"], name: "index_user_social_links_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preferences"
    t.string   "email",                                       null: false
    t.string   "crypted_password",                            null: false
    t.string   "salt",                                        null: false
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer  "failed_logins_count",             default: 0
    t.datetime "lock_expires_at"
    t.string   "unlock_token"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address"
    t.string   "twitter_username"
    t.string   "asset_token"
    t.string   "photo"
    t.datetime "photo_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at", using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

  add_foreign_key "image_attachments", "attachments"
  add_foreign_key "image_attachments", "images"
end
