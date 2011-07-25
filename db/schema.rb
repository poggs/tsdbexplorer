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

ActiveRecord::Schema.define(:version => 20110709170322) do

  create_table "associations", :force => true do |t|
    t.string   "main_train_uid"
    t.string   "assoc_train_uid"
    t.date     "association_start_date"
    t.date     "association_end_date"
    t.string   "association_days"
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
    t.date     "runs_from"
    t.date     "runs_to"
    t.boolean  "runs_mo"
    t.boolean  "runs_tu"
    t.boolean  "runs_we"
    t.boolean  "runs_th"
    t.boolean  "runs_fr"
    t.boolean  "runs_sa"
    t.boolean  "runs_su"
    t.string   "bh_running",                :limit => 1
    t.string   "category",                  :limit => 2
    t.string   "train_identity",            :limit => 4
    t.string   "train_identity_unique",     :limit => 10
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
    t.string   "stp_indicator",             :limit => 1
    t.string   "uic_code",                  :limit => 5
    t.string   "atoc_code",                 :limit => 2
    t.string   "ats_code",                  :limit => 1
    t.string   "rsid",                      :limit => 8
    t.string   "data_source",               :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "basic_schedules", ["train_identity"], :name => "index_basic_schedules_on_train_identity"
  add_index "basic_schedules", ["train_identity_unique"], :name => "index_basic_schedules_on_train_identity_unique"
  add_index "basic_schedules", ["train_uid"], :name => "index_basic_schedules_on_train_uid"
  add_index "basic_schedules", ["uuid"], :name => "index_basic_schedules_on_uuid"

  create_table "daily_schedule_locations", :force => true do |t|
    t.string   "daily_schedule_uuid",   :limit => 36
    t.string   "location_type",         :limit => 2
    t.string   "tiploc_code",           :limit => 7
    t.integer  "tiploc_instance"
    t.datetime "arrival"
    t.datetime "expected_arrival"
    t.datetime "actual_arrival"
    t.datetime "public_arrival"
    t.datetime "expected_pass"
    t.datetime "pass"
    t.datetime "actual_pass"
    t.datetime "expected_departure"
    t.datetime "departure"
    t.datetime "actual_departure"
    t.datetime "public_departure"
    t.string   "platform",              :limit => 3
    t.string   "actual_platform",       :limit => 3
    t.string   "line",                  :limit => 3
    t.string   "actual_line",           :limit => 3
    t.string   "path",                  :limit => 3
    t.string   "actual_path",           :limit => 3
    t.integer  "engineering_allowance"
    t.integer  "pathing_allowance"
    t.integer  "performance_allowance"
    t.string   "activity",              :limit => 12
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_schedule_locations", ["arrival"], :name => "index_daily_schedule_locations_on_arrival"
  add_index "daily_schedule_locations", ["daily_schedule_uuid"], :name => "index_daily_schedule_locations_on_daily_schedule_uuid"
  add_index "daily_schedule_locations", ["departure"], :name => "index_daily_schedule_locations_on_departure"
  add_index "daily_schedule_locations", ["pass"], :name => "index_daily_schedule_locations_on_pass"

  create_table "daily_schedules", :force => true do |t|
    t.string   "uuid",                      :limit => 36
    t.date     "runs_on"
    t.datetime "cancelled"
    t.string   "cancellation_reason",       :limit => 2
    t.string   "status",                    :limit => 1
    t.string   "train_uid",                 :limit => 6
    t.string   "category",                  :limit => 2
    t.string   "train_identity",            :limit => 4
    t.string   "train_identity_unique",     :limit => 10
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
    t.string   "stp_indicator",             :limit => 1
    t.string   "uic_code",                  :limit => 5
    t.string   "atoc_code",                 :limit => 2
    t.string   "ats_code",                  :limit => 1
    t.string   "rsid",                      :limit => 8
    t.string   "data_source",               :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_schedules", ["train_identity_unique"], :name => "index_daily_schedules_on_train_identity_unique"

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

  create_table "queued_messages", :force => true do |t|
    t.string   "queue_name"
    t.string   "message"
    t.integer  "state",      :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "temporary_speed_restrictions", :force => true do |t|
    t.string   "tsr_id"
    t.string   "route_group_name"
    t.string   "route_code"
    t.string   "route_order"
    t.string   "tsr_reference"
    t.string   "from_location"
    t.string   "to_location"
    t.string   "line_name"
    t.string   "subunit_type"
    t.integer  "mileage_from"
    t.integer  "subunit_from"
    t.integer  "mileage_to"
    t.integer  "subunit_to"
    t.string   "moving_mileage"
    t.integer  "passenger_speed"
    t.integer  "freight_speed"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.string   "reason"
    t.string   "requestor"
    t.string   "comments"
    t.string   "direction"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "temporary_speed_restrictions", ["route_code"], :name => "index_temporary_speed_restrictions_on_route_code"
  add_index "temporary_speed_restrictions", ["route_order"], :name => "index_temporary_speed_restrictions_on_route_order"
  add_index "temporary_speed_restrictions", ["tsr_id"], :name => "index_temporary_speed_restrictions_on_tsr_id"

  create_table "tiplocs", :force => true do |t|
    t.string "tiploc_code",     :limit => 7
    t.string "nalco",           :limit => 6
    t.string "tps_description", :limit => 26
    t.string "stanox",          :limit => 5
    t.string "crs_code",        :limit => 3
    t.string "description",     :limit => 16
  end

  add_index "tiplocs", ["crs_code"], :name => "index_tiplocs_on_crs_code"
  add_index "tiplocs", ["stanox"], :name => "index_tiplocs_on_stanox"
  add_index "tiplocs", ["tiploc_code"], :name => "index_tiplocs_on_tiploc_code", :unique => true

end
