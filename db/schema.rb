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

ActiveRecord::Schema.define(:version => 20090127104355) do

  create_table "constituencies", :force => true do |t|
    t.string  "name"
    t.string  "member_name"
    t.string  "member_party"
    t.string  "member_email"
    t.string  "member_biography_url"
    t.boolean "member_visible"
    t.string  "member_website"
    t.string  "member_requested_contact_url"
    t.integer "ons_id"
  end

  add_index "constituencies", ["ons_id"], :name => "index_constituencies_on_ons_id"

  create_table "members", :force => true do |t|
    t.string  "name"
    t.integer "constituency_id"
  end

  add_index "members", ["constituency_id"], :name => "index_members_on_constituency_id"

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authenticity_token"
    t.string   "recipient_email"
    t.boolean  "sender_is_constituent"
    t.string   "constituency_name"
    t.boolean  "attempted_send"
    t.string   "mailer_error"
    t.datetime "sent_at"
  end

  add_index "messages", ["attempted_send"], :name => "index_messages_on_attempted_send"
  add_index "messages", ["sent"], :name => "index_messages_on_sent"
  add_index "messages", ["sent_at"], :name => "index_messages_on_sent_at"

  create_table "postcodes", :force => true do |t|
    t.string  "code",            :limit => 7
    t.integer "constituency_id"
    t.integer "ons_id"
  end

  add_index "postcodes", ["constituency_id"], :name => "index_postcodes_on_constituency_id"
  add_index "postcodes", ["ons_id"], :name => "index_postcodes_on_ons_id"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope",          :limit => 40
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

end
