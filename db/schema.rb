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

ActiveRecord::Schema.define(:version => 20130523144325) do

  create_table "blacklisted_postcodes", :force => true do |t|
    t.string   "code",            :limit => 7
    t.integer  "constituency_id"
    t.string   "ons_id",          :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklisted_postcodes", ["code"], :name => "index_blacklisted_postcodes_on_code"

  create_table "constituencies", :force => true do |t|
    t.string   "name"
    t.string   "member_name"
    t.string   "member_party"
    t.string   "member_email"
    t.string   "member_biography_url"
    t.boolean  "member_visible"
    t.string   "member_website"
    t.string   "member_requested_contact_url"
    t.string   "ons_id",                       :limit => 20
    t.datetime "updated_at"
  end

  add_index "constituencies", ["ons_id"], :name => "index_constituencies_on_ons_id"

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_on"
  end

  create_table "manual_postcodes", :force => true do |t|
    t.string   "code",            :limit => 7
    t.integer  "constituency_id"
    t.string   "ons_id",          :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "manual_postcodes", ["code"], :name => "index_manual_postcodes_on_code"

  create_table "message_summaries", :force => true do |t|
    t.string   "constituency_name"
    t.string   "recipient"
    t.string   "recipient_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "sent_month"
    t.integer  "count"
  end

  add_index "message_summaries", ["constituency_name"], :name => "index_message_summaries_on_constituency_name"
  add_index "message_summaries", ["recipient"], :name => "index_message_summaries_on_recipient"
  add_index "message_summaries", ["recipient_email"], :name => "index_message_summaries_on_recipient_email"
  add_index "message_summaries", ["sent_month"], :name => "index_message_summaries_on_sent_month"

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
    t.string   "mailer_error"
    t.datetime "sent_at"
    t.string   "sender_ip_address"
  end

  add_index "messages", ["sent"], :name => "index_messages_on_sent"
  add_index "messages", ["sent_at"], :name => "index_messages_on_sent_at"

  create_table "postcode_districts", :force => true do |t|
    t.string  "district",        :limit => 4
    t.integer "constituency_id"
  end

  add_index "postcode_districts", ["district"], :name => "index_postcode_districts_on_district"

  create_table "postcodes", :force => true do |t|
    t.string  "code",            :limit => 7
    t.integer "constituency_id"
    t.string  "ons_id",          :limit => 20
  end

  add_index "postcodes", ["code"], :name => "index_postcodes_on_code"
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

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "perishable_token",  :default => "",    :null => false
    t.string   "email",             :default => "",    :null => false
    t.boolean  "admin",             :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
