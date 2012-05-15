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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120507153751) do

  create_table "associations", :force => true do |t|
    t.string   "main_train_uid"
    t.string   "assoc_train_uid"
    t.date     "association_start_date"
    t.date     "association_end_date"
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
    t.boolean  "valid_mo"
    t.boolean  "valid_tu"
    t.boolean  "valid_we"
    t.boolean  "valid_th"
    t.boolean  "valid_fr"
    t.boolean  "valid_sa"
    t.boolean  "valid_su"
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
    t.string   "catering_code",             :limit => 4
    t.string   "service_branding",          :limit => 1
    t.string   "stp_indicator",             :limit => 1
    t.string   "uic_code",                  :limit => 5
    t.string   "atoc_code",                 :limit => 2
    t.string   "ats_code",                  :limit => 1
    t.string   "rsid",                      :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_source",               :limit => 16
    t.boolean  "oper_q"
    t.boolean  "oper_y"
  end

  add_index "basic_schedules", ["runs_fr"], :name => "index_basic_schedules_on_runs_fr"
  add_index "basic_schedules", ["runs_mo"], :name => "index_basic_schedules_on_runs_mo"
  add_index "basic_schedules", ["runs_sa"], :name => "index_basic_schedules_on_runs_sa"
  add_index "basic_schedules", ["runs_su"], :name => "index_basic_schedules_on_runs_su"
  add_index "basic_schedules", ["runs_th"], :name => "index_basic_schedules_on_runs_th"
  add_index "basic_schedules", ["runs_tu"], :name => "index_basic_schedules_on_runs_tu"
  add_index "basic_schedules", ["runs_we"], :name => "index_basic_schedules_on_runs_we"
  add_index "basic_schedules", ["train_identity"], :name => "index_basic_schedules_on_train_identity"
  add_index "basic_schedules", ["train_identity_unique"], :name => "index_basic_schedules_on_train_identity_unique"
  add_index "basic_schedules", ["train_uid"], :name => "index_basic_schedules_on_train_uid"
  add_index "basic_schedules", ["uuid"], :name => "index_basic_schedules_on_uuid"

  create_table "cif_files", :force => true do |t|
    t.string   "file_ref",                :limit => 7
    t.datetime "extract_timestamp"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "update_indicator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_mainframe_identity", :limit => 20
    t.string   "mainframe_username",      :limit => 6
    t.date     "extract_date"
  end

  create_table "daily_schedule_locations", :force => true do |t|
    t.string   "daily_schedule_uuid",    :limit => 36
    t.string   "location_type",          :limit => 2
    t.string   "tiploc_code",            :limit => 7
    t.integer  "tiploc_instance"
    t.boolean  "cancelled"
    t.datetime "cancellation_timestamp"
    t.string   "cancellation_reason",    :limit => 2
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
    t.string   "platform",               :limit => 3
    t.string   "actual_platform",        :limit => 3
    t.string   "line",                   :limit => 3
    t.string   "actual_line",            :limit => 3
    t.string   "path",                   :limit => 3
    t.string   "actual_path",            :limit => 3
    t.integer  "engineering_allowance"
    t.integer  "pathing_allowance"
    t.integer  "performance_allowance"
    t.string   "activity",               :limit => 12
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "arrival_source",         :limit => 16
    t.string   "pass_source",            :limit => 16
    t.string   "departure_source",       :limit => 16
    t.string   "arrival_system",         :limit => 20
    t.string   "arrival_device_id",      :limit => 8
    t.string   "arrival_username",       :limit => 8
    t.string   "pass_system",            :limit => 20
    t.string   "pass_device_id",         :limit => 8
    t.string   "pass_username",          :limit => 8
    t.string   "departure_system",       :limit => 20
    t.string   "departure_device_id",    :limit => 8
    t.string   "departure_username",     :limit => 8
    t.string   "event_source",           :limit => 1
    t.integer  "seq"
    t.boolean  "activity_ae"
    t.boolean  "activity_bl"
    t.boolean  "activity_minusd"
    t.boolean  "activity_hh"
    t.boolean  "activity_kc"
    t.boolean  "activity_ke"
    t.boolean  "activity_kf"
    t.boolean  "activity_ks"
    t.boolean  "activity_op"
    t.boolean  "activity_or"
    t.boolean  "activity_pr"
    t.boolean  "activity_rm"
    t.boolean  "activity_rr"
    t.boolean  "activity_minust"
    t.boolean  "activity_tb"
    t.boolean  "activity_tf"
    t.boolean  "activity_ts"
    t.boolean  "activity_tw"
    t.boolean  "activity_minusu"
    t.boolean  "activity_a"
    t.boolean  "activity_c"
    t.boolean  "activity_d"
    t.boolean  "activity_e"
    t.boolean  "activity_g"
    t.boolean  "activity_h"
    t.boolean  "activity_k"
    t.boolean  "activity_l"
    t.boolean  "activity_n"
    t.boolean  "activity_r"
    t.boolean  "activity_s"
    t.boolean  "activity_t"
    t.boolean  "activity_u"
    t.boolean  "activity_w"
    t.boolean  "activity_x"
  end

  add_index "daily_schedule_locations", ["arrival"], :name => "index_daily_schedule_locations_on_arrival"
  add_index "daily_schedule_locations", ["daily_schedule_uuid"], :name => "index_daily_schedule_locations_on_daily_schedule_uuid"
  add_index "daily_schedule_locations", ["departure"], :name => "index_daily_schedule_locations_on_departure"
  add_index "daily_schedule_locations", ["pass"], :name => "index_daily_schedule_locations_on_pass"

  create_table "daily_schedules", :force => true do |t|
    t.string   "uuid",                      :limit => 36
    t.date     "runs_on"
    t.boolean  "cancelled"
    t.datetime "cancellation_timestamp"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_source",               :limit => 16
    t.integer  "last_location"
  end

  add_index "daily_schedules", ["train_identity_unique"], :name => "index_daily_schedules_on_train_identity_unique"

  create_table "geo_elrs", :force => true do |t|
    t.string   "elr_code",   :limit => 4
    t.text     "line_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_points", :force => true do |t|
    t.text     "location_name"
    t.string   "route_code",    :limit => 6
    t.string   "elr_code",      :limit => 4
    t.integer  "miles"
    t.integer  "chains"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "engineering_allowance", :limit => 2
    t.string   "pathing_allowance",     :limit => 2
    t.string   "performance_allowance", :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seq"
    t.boolean  "activity_ae"
    t.boolean  "activity_bl"
    t.boolean  "activity_minusd"
    t.boolean  "activity_hh"
    t.boolean  "activity_kc"
    t.boolean  "activity_ke"
    t.boolean  "activity_kf"
    t.boolean  "activity_ks"
    t.boolean  "activity_op"
    t.boolean  "activity_or"
    t.boolean  "activity_pr"
    t.boolean  "activity_rm"
    t.boolean  "activity_rr"
    t.boolean  "activity_minust"
    t.boolean  "activity_tb"
    t.boolean  "activity_tf"
    t.boolean  "activity_ts"
    t.boolean  "activity_tw"
    t.boolean  "activity_minusu"
    t.boolean  "activity_a"
    t.boolean  "activity_c"
    t.boolean  "activity_d"
    t.boolean  "activity_e"
    t.boolean  "activity_g"
    t.boolean  "activity_h"
    t.boolean  "activity_k"
    t.boolean  "activity_l"
    t.boolean  "activity_n"
    t.boolean  "activity_r"
    t.boolean  "activity_s"
    t.boolean  "activity_t"
    t.boolean  "activity_u"
    t.boolean  "activity_w"
    t.boolean  "activity_x"
    t.boolean  "next_day_arrival"
    t.boolean  "next_day_departure"
    t.integer  "arrival_secs"
    t.integer  "departure_secs"
    t.integer  "pass_secs"
    t.integer  "public_arrival_secs"
    t.integer  "public_departure_secs"
  end

  add_index "locations", ["arrival"], :name => "index_locations_on_arrival"
  add_index "locations", ["basic_schedule_uuid"], :name => "index_locations_on_basic_schedule_uuid"
  add_index "locations", ["departure"], :name => "index_locations_on_departure"
  add_index "locations", ["location_type"], :name => "index_locations_on_location_type"
  add_index "locations", ["pass"], :name => "index_locations_on_pass"
  add_index "locations", ["tiploc_code"], :name => "index_locations_on_tiploc_code"

  create_table "points", :force => true do |t|
    t.text     "full_name"
    t.text     "short_name"
    t.integer  "stanox"
    t.string   "stanme",     :limit => 9
    t.string   "tiploc",     :limit => 7
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "queued_messages", :force => true do |t|
    t.string   "queue_name"
    t.string   "message"
    t.integer  "state",      :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "td_areas", :force => true do |t|
    t.string   "td_area",    :limit => 2
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "td_berths", :force => true do |t|
    t.string   "td_area_id", :limit => 2
    t.string   "berth",      :limit => 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "td_maps", :force => true do |t|
    t.text     "name"
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
    t.datetime "creation_date"
    t.datetime "valid_from_date"
    t.datetime "valid_to_date"
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
    t.string  "tiploc_code",     :limit => 7
    t.string  "nalco",           :limit => 6
    t.string  "tps_description", :limit => 26
    t.string  "stanox",          :limit => 5
    t.string  "crs_code",        :limit => 3
    t.string  "description",     :limit => 16
    t.float   "geo_lat"
    t.float   "geo_lon"
    t.boolean "is_public"
    t.string  "nalco_four",      :limit => 4
  end

  add_index "tiplocs", ["crs_code"], :name => "index_tiplocs_on_crs_code"
  add_index "tiplocs", ["stanox"], :name => "index_tiplocs_on_stanox"
  add_index "tiplocs", ["tiploc_code"], :name => "index_tiplocs_on_tiploc_code", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.text     "full_name"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "is_admin"
    t.boolean  "enabled"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
