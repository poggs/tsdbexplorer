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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110626161616) do

  create_table "associations", :force => true do |t|
    t.string   "main_train_uid"
    t.string   "assoc_train_uid"
    t.date     "date"
    t.string   "category"
    t.string   "date_indicator"
    t.string   "location"
    t.string   "base_location_suffix"
    t.string   "assoc_location_suffix"
    t.string   "diagram_type"
    t.string   "assoc_type"
    t.string   "stp_indicator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "basic_schedules", :force => true do |t|
    t.string   "uuid",                      :limit => 36
    t.string   "train_uid",                 :limit => 6
    t.string   "status",                    :limit => 1
    t.date     "run_date"
    t.string   "category",                  :limit => 2
    t.string   "train_identity",            :limit => 4
    t.string   "headcode",                  :limit => 4
    t.string   "service_code",              :limit => 8
    t.string   "portion_id",                :limit => 1
    t.string   "power_type",                :limit => 3
    t.string   "timing_load",               :limit => 4
    t.string   "speed",                     :limit => 3
    t.string   "operating_characteristics", :limit => 6
    t.string   "train_class",               :limit => 1
    t.string   "sleepers",                  :limit => 1
    t.string   "reservations",              :limit => 1
    t.string   "catering_code",             :limit => 1
    t.string   "service_branding",          :limit => 1
    t.string   "uic_code",                  :limit => 5
    t.string   "atoc_code",                 :limit => 2
    t.string   "ats_code",                  :limit => 1
    t.string   "rsid",                      :limit => 8
    t.string   "data_source",               :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "basic_schedules", ["run_date"], :name => "index_basic_schedules_on_run_date"
  add_index "basic_schedules", ["train_uid"], :name => "index_basic_schedules_on_train_uid"
  add_index "basic_schedules", ["uuid"], :name => "index_basic_schedules_on_uuid"

  create_table "locations", :force => true do |t|
    t.string   "basic_schedule_uuid",   :limit => 36
    t.string   "location_type",         :limit => 2
    t.string   "tiploc_code",           :limit => 7
    t.integer  "tiploc_instance"
    t.string   "arrival",               :limit => 5
    t.string   "public_arrival",        :limit => 5
    t.string   "pass",                  :limit => 5
    t.string   "departure",             :limit => 5
    t.string   "public_departure",      :limit => 5
    t.string   "platform",              :limit => 3
    t.string   "line",                  :limit => 3
    t.string   "path",                  :limit => 3
    t.integer  "engineering_allowance"
    t.integer  "pathing_allowance"
    t.integer  "performance_allowance"
    t.string   "activity",              :limit => 12
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["arrival"], :name => "index_locations_on_arrival"
  add_index "locations", ["basic_schedule_uuid"], :name => "index_locations_on_basic_schedule_uuid"
  add_index "locations", ["departure"], :name => "index_locations_on_departure"
  add_index "locations", ["pass"], :name => "index_locations_on_pass"

  create_table "tiplocs", :force => true do |t|
    t.string   "tiploc_code",     :limit => 7
    t.string   "nalco",           :limit => 6
    t.string   "tps_description", :limit => 26
    t.string   "stanox",          :limit => 5
    t.string   "crs_code",        :limit => 3
    t.string   "description",     :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tiplocs", ["crs_code"], :name => "index_tiplocs_on_crs_code"
  add_index "tiplocs", ["tiploc_code"], :name => "index_tiplocs_on_tiploc_code", :unique => true

end
