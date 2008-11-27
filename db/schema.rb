# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081127144634) do

  create_table "constituencies", :force => true do |t|
    t.string "name"
    t.string "member_name"
  end

  create_table "messages", :force => true do |t|
    t.string   "constituency_id"
    t.string   "sender_email"
    t.string   "sender"
    t.string   "recipient"
    t.string   "address"
    t.string   "postcode"
    t.string   "subject"
    t.text     "message"
    t.boolean  "sent"
    t.time     "sent_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "postcodes", :force => true do |t|
    t.string  "code",            :limit => 7
    t.integer "constituency_id"
  end

  add_index "postcodes", ["constituency_id"], :name => "index_postcodes_on_constituency_id"

end
