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

ActiveRecord::Schema.define(version: 20180519000000) do

  create_table "parents", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.boolean  "active"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer  "vendor_id"
    t.string   "title"
    t.decimal  "price"
    t.boolean  "active"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "publish_at"
    t.integer  "status",     default: 0
  end

  add_index "products", ["vendor_id"], name: "index_products_on_vendor_id"

  create_table "products_tags", id: false, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "product_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.boolean  "active"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "parent_id"
  end

  add_index "vendors", ["parent_id"], name: "index_vendors_on_parent_id"

end
