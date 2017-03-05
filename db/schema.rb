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

ActiveRecord::Schema.define(version: 20170301170210) do

  create_table "currency_converters", force: :cascade do |t|
    t.string   "currency_slug",    limit: 3
    t.string   "description",      limit: 255
    t.boolean  "default_currency",             default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "currency_converters", ["currency_slug"], name: "index_currency_converters_on_currency_slug", unique: true, using: :btree

  create_table "exchange_rates", force: :cascade do |t|
    t.decimal  "rate",                            precision: 16, scale: 5
    t.date     "ecb_time"
    t.integer  "currency_converter_id", limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "exchange_rates", ["ecb_time", "currency_converter_id"], name: "index_exchange_rates_on_ecb_time_and_currency_converter_id", unique: true, using: :btree

end
