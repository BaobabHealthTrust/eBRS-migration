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

ActiveRecord::Schema.define(version: 20170912104756) do

  create_table "couchdb_sequence", primary_key: "couchdb_sequence_id", force: :cascade do |t|
    t.bigint "seq", limit: 4, null: false
  end

  create_table "ebrs_migration", primary_key: "ebrs_migration_id", force: :cascade do |t|
    t.bigint  "page_size"
    t.bigint  "current_page"
    t.integer "file_number"
  end  

  create_table "audit_trail_types", primary_key: "audit_trail_type_id", force: :cascade do |t|
    t.string   "name",       limit: 20
    t.bigint  "creator",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audit_trails", primary_key: "audit_trail_id", force: :cascade do |t|
    t.integer  "audit_trail_type_id", limit: 4,   null: false
    t.bigint   "person_id",           limit: 4,   null: false
    t.string   "table_name",          limit: 100
    t.bigint   "table_row_id",        limit: 4
    t.string   "field",               limit: 50
    t.string   "previous_value",      limit: 255
    t.string   "current_value",       limit: 255
    t.string   "comment",             limit: 255
    t.integer  "location_id",         limit: 4,   null: false
    t.string   "ip_address"
    t.string   "mac_address"
    t.bigint   "creator",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  change_column :audit_trails, :audit_trail_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "audit_trails", ["audit_trail_type_id"], name: "fk_audit_trails_1", using: :btree
  add_index "audit_trails", ["creator"], name: "fk_audit_trails_3", using: :btree
  add_index "audit_trails", ["location_id"], name: "fk_audit_trails_2", using: :btree
  add_index "audit_trails", ["person_id"], name: "fk_audit_trails_4", using: :btree

  create_table "birth_registration_type", primary_key: "birth_registration_type_id", force: :cascade do |t|
    t.string   "name",        limit: 45,                  null: false
    t.boolean  "voided",                  default: false, null: false
    t.string   "void_reason", limit: 100
    t.bigint  "voided_by",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "birth_registration_type", ["birth_registration_type_id"], name: "birth_registration_type_id_UNIQUE", unique: true, using: :btree

  create_table "core_person", primary_key: "person_id", force: :cascade do |t|
    t.integer  "person_type_id", limit: 4, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end


  change_column :core_person, :person_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "core_person", ["person_id"], name: "person_id_UNIQUE", unique: true, using: :btree
  add_index "core_person", ["person_type_id"], name: "fk_core_person_1_idx", using: :btree


  create_table "global_property", primary_key: "global_property_id", force: :cascade do |t|
    t.string   "property",   limit: 50, null: false
    t.string   "value",      limit: 50, null: false
    t.string   "uuid",       limit: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_property", ["property"], name: "fk_global_property_1_idx", using: :btree

  create_table "identifier_allocation_queue", primary_key: "identifier_allocation_queue_id", force: :cascade do |t|
    t.bigint  "person_id",       limit: 4,               null: false
    t.integer  "person_identifier_type_id", limit: 4,             null: false
    t.integer  "assigned",                  limit: 1, default: 0, null: false
    t.bigint  "creator",                   limit: 4,             null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  change_column :identifier_allocation_queue, :identifier_allocation_queue_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "identifier_allocation_queue", ["person_id"], name: "fk_identifier_allocation_queue_1_idx", using: :btree
  add_index "identifier_allocation_queue", ["person_identifier_type_id"], name: "fk_identifier_allocation_queue_2", using: :btree

  create_table "level_of_education", primary_key: "level_of_education_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "location", primary_key: "location_id", force: :cascade do |t|
    t.string   "code",            limit: 45
    t.string   "name",            limit: 255, default: "",    null: false
    t.string   "description",     limit: 255
    t.string   "postal_code",     limit: 50
    t.string   "country",         limit: 50
    t.string   "latitude",        limit: 50
    t.string   "longitude",       limit: 50
    t.bigint  "creator",         limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                  null: false
    t.string   "county_district", limit: 255
    t.boolean  "voided",                      default: false, null: false
    t.bigint  "voided_by",       limit: 4
    t.datetime "date_voided"
    t.string   "void_reason",     limit: 255
    t.integer  "parent_location", limit: 4
    t.string   "uuid",            limit: 38,                  null: false
    t.bigint  "changed_by",      limit: 4
    t.datetime "changed_at"
  end

  add_index "location", ["changed_by"], name: "location_changed_by", using: :btree
  add_index "location", ["creator"], name: "user_who_created_location", using: :btree
  add_index "location", ["name"], name: "name_of_location", using: :btree
  add_index "location", ["parent_location"], name: "parent_location", using: :btree
  add_index "location", ["uuid"], name: "location_uuid_index", unique: true, using: :btree
  add_index "location", ["voided"], name: "retired_status", using: :btree
  add_index "location", ["voided_by"], name: "user_who_retired_location", using: :btree

  create_table "location_tag", primary_key: "location_tag_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.bigint  "voided_by",   limit: 4
    t.string   "void_reason", limit: 45
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "location_tag", ["location_tag_id"], name: "location_tag_map_id_UNIQUE", unique: true, using: :btree

  create_table "location_tag_map", id: false, force: :cascade do |t|
    t.integer "location_id",     limit: 4, null: false
    t.integer "location_tag_id", limit: 4, null: false
  end

  add_index "location_tag_map", ["location_id"], name: "fk_location_tag_map_1", using: :btree
  add_index "location_tag_map", ["location_tag_id"], name: "fk_location_tag_map_2_idx", using: :btree

  create_table "mode_of_delivery", primary_key: "mode_of_delivery_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "person", primary_key: "person_id", force: :cascade do |t|
    t.string   "gender",              limit: 6,             null: false
    t.integer  "birthdate_estimated", limit: 1, default: 0, null: false
    t.date     "birthdate",                                 null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  change_column  :person, :person_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  create_table "person_addresses", primary_key: "person_addresses_id", force: :cascade do |t|
    t.bigint  "person_id",              limit: 4,   null: false
    t.integer  "current_village",        limit: 4
    t.string   "current_village_other",  limit: 255
    t.integer  "current_ta",             limit: 4
    t.string   "current_ta_other",       limit: 255
    t.integer  "current_district",       limit: 4
    t.string   "current_district_other", limit: 255
    t.integer  "home_village",           limit: 4
    t.string   "home_village_other",     limit: 255
    t.integer  "home_ta",                limit: 4
    t.string   "home_ta_other",          limit: 255
    t.integer  "home_district",          limit: 4
    t.string   "home_district_other",    limit: 255
    t.integer  "citizenship",            limit: 4,   null: false
    t.integer  "residential_country",    limit: 4,   null: false
    t.string   "address_line_1",         limit: 255
    t.string   "address_line_2",         limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  change_column  :person_addresses, :person_addresses_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_addresses", ["citizenship"], name: "fk_person_addresses_8_idx", using: :btree
  add_index "person_addresses", ["current_district"], name: "fk_person_addresses_4_idx", using: :btree
  add_index "person_addresses", ["current_ta"], name: "fk_person_addresses_3_idx", using: :btree
  add_index "person_addresses", ["current_village", "current_ta", "current_district", "home_village", "home_ta", "home_district"], name: "fk_person_addresses_2_idx", using: :btree
  add_index "person_addresses", ["home_district"], name: "fk_person_addresses_7_idx", using: :btree
  add_index "person_addresses", ["home_ta"], name: "fk_person_addresses_6_idx", using: :btree
  add_index "person_addresses", ["home_village"], name: "fk_person_addresses_5_idx", using: :btree
  add_index "person_addresses", ["person_id"], name: "fk_person_addresses_1_idx", using: :btree

  create_table "person_attribute_types", primary_key: "person_attribute_type_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "person_attributes", primary_key: "person_attribute_id", force: :cascade do |t|
    t.bigint  "person_id",                limit: 4,               null: false
    t.integer  "person_attribute_type_id", limit: 4,               null: false
    t.integer  "voided",                   limit: 1,   default: 0, null: false
    t.string   "value",                    limit: 100,             null: false
    t.bigint  "voided_by",                limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  change_column  :person_attributes, :person_attribute_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_attributes", ["person_attribute_type_id"], name: "fk_person_attributes_2_idx", using: :btree
  add_index "person_attributes", ["person_id"], name: "fk_person_attributes_1_idx", using: :btree

  create_table "person_identifier_types", primary_key: "person_identifier_type_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.string   "document_id", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "person_identifiers", primary_key: "person_identifier_id", force: :cascade do |t|
    t.bigint  "person_id",                limit: 4,               null: false
    t.integer  "person_identifier_type_id", limit: 4,               null: false
    t.integer  "voided",                   limit: 1,   default: 0, null: false
    t.string   "value",                    limit: 100,             null: false
    t.bigint  "voided_by",                limit: 4
    t.datetime "date_voided"
    t.string   "document_id", limit: 100
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  change_column  :person_identifiers, :person_identifier_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_identifiers", ["person_identifier_type_id"], name: "fk_person_identifiers_2_idx", using: :btree
  add_index "person_identifiers", ["person_id"], name: "fk_person_identifiers_1_idx", using: :btree

  create_table "person_birth_details", primary_key: "person_birth_details_id", force: :cascade do |t|
    t.bigint  "person_id",                               limit: 4,              null: false
    t.integer  "place_of_birth",                          limit: 4,              null: false
    t.integer  "district_of_birth",                       limit: 4,              null: false
    t.integer  "birth_location_id",                       limit: 4,              null: false
    t.string   "other_birth_location",                    limit: 45
    t.float    "birth_weight",                            limit: 24
    t.integer  "type_of_birth",                           limit: 4,               null: false
    t.string   "other_type_of_birth",                      limit: 255
    t.integer  "parents_married_to_each_other",           limit: 1,   default: 0, null: false
    t.date     "date_of_marriage"
    t.integer  "gestation_at_birth",                      limit: 4
    t.integer  "number_of_prenatal_visits",               limit: 4
    t.integer  "month_prenatal_care_started",             limit: 4
    t.integer  "mode_of_delivery_id",                     limit: 4,               null: false
    t.integer  "number_of_children_born_alive_inclusive", limit: 4,   default: 1, null: false
    t.integer  "number_of_children_born_still_alive",     limit: 4,   default: 1, null: false
    t.integer  "level_of_education_id",                   limit: 4,               null: false
    t.string   "district_id_number",                      limit: 20
    t.integer  "national_serial_number",                  limit: 4
    t.integer  "court_order_attached",                    limit: 1,   default: 0, null: false
    t.integer  "parents_signed",                          limit: 1,   default: 0, null: false
    t.date     "acknowledgement_of_receipt_date",                                 null: false
    t.string   "facility_serial_number",                  limit: 30
    t.integer  "adoption_court_order",                    limit: 1,   default: 0, null: false
    t.integer  "birth_registration_type_id",              limit: 4,               null: false
    t.integer  "location_created_at",                     limit: 4
    t.integer  "form_signed",                             limit: 1,   default: 0, null: false
    t.string   "informant_relationship_to_person",        limit: 255
    t.string   "other_informant_relationship_to_person",  limit: 255
    t.string   "informant_designation",                   limit: 255
    t.string   "level",                                   limit: 10
    t.string   "source_id",                               limit: 255
    t.integer  "flagged",                                 limit: 1,   default: 0, null: false
    t.date     "date_reported",                                                   null: false
    t.date     "date_registered"
    t.string   "source_id"
    t.integer  "flagged",                   limit: 1,   default: 0, null: false
    t.bigint   "creator",                                 limit: 4,               null: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  change_column  :person_birth_details, :person_birth_details_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_birth_details", ["birth_location_id"], name: "fk_person_birth_details_3_idx", using: :btree
  add_index "person_birth_details", ["birth_registration_type_id"], name: "fk_person_birth_details_8_idx", using: :btree
  add_index "person_birth_details", ["creator"], name: "fk_person_birth_details_9", using: :btree
  add_index "person_birth_details", ["district_id_number"], name: "district_id_number_UNIQUE", unique: true, using: :btree
  add_index "person_birth_details", ["facility_serial_number"], name: "facility_serial_number_UNIQUE", unique: true, using: :btree
  add_index "person_birth_details", ["level_of_education_id"], name: "fk_person_birth_details_7_idx", using: :btree
  add_index "person_birth_details", ["location_created_at"], name: "fk_person_birth_details_6_idx", using: :btree
  add_index "person_birth_details", ["mode_of_delivery_id"], name: "fk_person_birth_details_5_idx", using: :btree
  add_index "person_birth_details", ["national_serial_number"], name: "national_serial_number_UNIQUE", unique: true, using: :btree
  add_index "person_birth_details", ["person_id"], name: "fk_person_birth_details_1_idx", using: :btree
  add_index "person_birth_details", ["place_of_birth"], name: "fk_person_birth_details_4_idx", using: :btree
  add_index "person_birth_details", ["type_of_birth"], name: "fk_person_birth_details_2_idx", using: :btree


  create_table "person_name", primary_key: "person_name_id", force: :cascade do |t|
    t.bigint  "person_id",   limit: 4,               null: false
    t.string   "first_name",  limit: 50,              null: false
    t.string   "middle_name", limit: 50
    t.string   "last_name",   limit: 50,              null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  change_column  :person_name, :person_name_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_name", ["person_id"], name: "fk_person_name_1_idx", using: :btree
  add_index "person_name", ["voided_by"], name: "fk_person_name_2_idx", using: :btree

  create_table "person_name_code", primary_key: "person_name_code_id", force: :cascade do |t|
    t.bigint  "person_name_id",   limit: 4,  null: false
    t.string   "first_name_code",  limit: 10, null: false
    t.string   "middle_name_code", limit: 10
    t.string   "last_name_code",   limit: 10, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  change_column  :person_name_code, :person_name_code_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_name_code", ["person_name_id"], name: "fk_person_name_code_1_idx", using: :btree

  create_table "person_record_statuses", primary_key: "person_record_status_id", force: :cascade do |t|
    t.integer  "status_id",   limit: 4,     null: false
    t.bigint  "person_id",   limit: 4,     null: false
    t.bigint  "creator",     limit: 4,     null: false
    t.integer  "voided",      limit: 1
    t.string   "void_reason", limit: 100
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.text     "comments",    limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  change_column  :person_record_statuses, :person_record_status_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_record_statuses", ["person_id"], name: "fk_person_record_statuses_1_idx", using: :btree
  add_index "person_record_statuses", ["status_id"], name: "fk_person_record_statuses_2_idx", using: :btree
  add_index "person_record_statuses", ["voided_by"], name: "fk_person_record_statuses_3_idx", using: :btree

  create_table "person_relationship", primary_key: "person_relationship_id", force: :cascade do |t|
    t.bigint  "person_a",                    limit: 4, null: false
    t.bigint  "person_b",                    limit: 4, null: false
    t.integer  "person_relationship_type_id", limit: 4, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  change_column  :person_relationship, :person_relationship_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_index "person_relationship", ["person_a"], name: "fk_person_relationship_1_idx", using: :btree
  add_index "person_relationship", ["person_b"], name: "fk_person_relationship_2_idx", using: :btree
  add_index "person_relationship", ["person_relationship_type_id"], name: "fk_person_relationship_3_idx", using: :btree

  create_table "person_relationship_types", primary_key: "person_relationship_type_id", force: :cascade do |t|
    t.string   "name",        limit: 25,             null: false
    t.integer  "voided",      limit: 1,  default: 0, null: false
    t.string   "description", limit: 45
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "person_type", primary_key: "person_type_id", force: :cascade do |t|
    t.string "name",        limit: 45, null: false
    t.string "description", limit: 45
  end

  create_table "person_type_of_births", primary_key: "person_type_of_birth_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.bigint  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "role", primary_key: "role_id", force: :cascade do |t|
    t.string "role",  limit: 50, default: "", null: false
    t.string "level", limit: 10
  end

  add_index "role", ["role_id"], name: "fk_user_role_1_idx", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "statuses", primary_key: "status_id", force: :cascade do |t|
    t.string   "name",        limit: 45
    t.string   "description", limit: 100
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "user_role", primary_key: "user_role_id", force: :cascade do |t|
    t.bigint "user_id", limit: 4, null: false
    t.integer "role_id", limit: 4, null: false
  end

  add_index "user_role", ["role_id"], name: "fk_user_role_2_idx", using: :btree
  add_index "user_role", ["user_id"], name: "fk_user_role_1_idx", using: :btree

  create_table "users", primary_key: "user_id", force: :cascade do |t|
    t.integer  "location_id",        limit: 4
    t.string   "username",           limit: 50,                  null: false
    t.string   "plain_password",     limit: 255
    t.string   "password_hash",      limit: 255
    t.bigint  "creator",            limit: 4,   default: 0,     null: false
    t.bigint  "person_id",          limit: 4
    t.integer  "active",             limit: 1,   default: 1,     null: false
    t.string   "un_or_block_reason", limit: 225
    t.integer  "voided",             limit: 1,   default: 0,     null: false
    t.bigint  "voided_by",          limit: 4
    t.datetime "date_voided"
    t.string   "void_reason",        limit: 255
    t.string   "email",              limit: 225
    t.integer  "notify",             limit: 1,   default: 0,     null: false
    t.string   "preferred_keyboard", limit: 10,  default: "abc", null: false
    t.bigint  "password_attempt",   limit: 4,   default: 0
    t.datetime "last_password_date"
    t.string   "uuid",               limit: 38
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  change_column  :users, :user_id, 'bigint(20) NOT NULL AUTO_INCREMENT'


  ############################ Resoving Potential Duplicate tables ##########################################################

  create_table "potential_duplicates", primary_key: "potential_duplicate_id", force: :cascade do |t|
    t.bigint  "person_id", limit: 4, null: false
    t.string   "resolved",      limit: 1,   default: 0,     null: false
    t.string   "decision",      limit: 255
    t.string   "comment",      limit: 255
    t.datetime "resolved_at"
    t.datetime "created_at"
  end

  change_column  :potential_duplicates, :potential_duplicate_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_foreign_key "potential_duplicates", "person", primary_key: "person_id", name: "fk_potential_duplicates_1"

  create_table "duplicate_records", primary_key: "duplicate_record_id", force: :cascade do |t|
    t.bigint  "person_id", limit: 4
    t.bigint   "potential_duplicate_id",      limit: 4
    t.datetime "created_at"
  end

  change_column  :duplicate_records, :duplicate_record_id, 'bigint(20) NOT NULL AUTO_INCREMENT'

  add_foreign_key "duplicate_records", "potential_duplicates", primary_key: "potential_duplicate_id", name: "fk_duplicate_records_1"
  add_foreign_key "duplicate_records", "person", primary_key: "person_id", name: "fk_duplicate_records_2"

  create_table "barcode_identifiers", primary_key: "barcode_identifier_id", force: :cascade do |t|
    t.string   "value",      limit: 20, null: false
    t.integer  "assigned",   limit: 1,   default: 0, null: false
    t.bigint  "person_id", limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_foreign_key "barcode_identifiers", "person", primary_key: "person_id", name: "fk_barcode_identifiers_1"
  add_index "barcode_identifiers", ["value"], name: "value_UNIQUE", unique: true, using: :btree
  ##########################################################################################################################

  add_index "users", ["person_id"], name: "fk_users_1_idx", using: :btree
  add_index "users", ["username"], name: "username_UNIQUE", unique: true, using: :btree
  add_index "users", ["voided_by"], name: "fk_users_2_idx", using: :btree

  add_foreign_key "audit_trails", "audit_trail_types", primary_key: "audit_trail_type_id", name: "fk_audit_trails_1"
  add_foreign_key "audit_trails", "core_person", column: "person_id", primary_key: "person_id", name: "fk_audit_trails_4"
  add_foreign_key "audit_trails", "location", primary_key: "location_id", name: "fk_audit_trails_2"
  add_foreign_key "audit_trails", "users", column: "creator", primary_key: "user_id", name: "fk_audit_trails_3"
  add_foreign_key "core_person", "person_type", primary_key: "person_type_id", name: "fk_core_person_1"
  #add_foreign_key "duplicate_records", "person", primary_key: "person_id", name: "fk_duplicate_records_2"
  #add_foreign_key "duplicate_records", "potential_duplicates", primary_key: "potential_duplicate_id", name: "fk_duplicate_records_1"
  add_foreign_key "identifier_allocation_queue", "core_person", column: "person_id", primary_key: "person_id", name: "fk_identifier_allocation_queue_1"
  add_foreign_key "identifier_allocation_queue", "person_identifier_types", primary_key: "person_identifier_type_id", name: "fk_identifier_allocation_queue_2"
  add_foreign_key "location_tag_map", "location", primary_key: "location_id", name: "fk_location_tag_map_1"
  add_foreign_key "location_tag_map", "location_tag", primary_key: "location_tag_id", name: "fk_location_tag_map_2"
  add_foreign_key "person", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_1"
  add_foreign_key "person_addresses", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_addresses_1"
  add_foreign_key "person_addresses", "location", column: "current_district", primary_key: "location_id", name: "fk_person_addresses_4"
  add_foreign_key "person_addresses", "location", column: "current_ta", primary_key: "location_id", name: "fk_person_addresses_3"
  add_foreign_key "person_addresses", "location", column: "current_village", primary_key: "location_id", name: "fk_person_addresses_2"
  add_foreign_key "person_addresses", "location", column: "home_district", primary_key: "location_id", name: "fk_person_addresses_7"
  add_foreign_key "person_addresses", "location", column: "home_ta", primary_key: "location_id", name: "fk_person_addresses_6"
  add_foreign_key "person_addresses", "location", column: "home_village", primary_key: "location_id", name: "fk_person_addresses_5"
  add_foreign_key "person_attributes", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_attributes_1"
  add_foreign_key "person_attributes", "person_attribute_types", primary_key: "person_attribute_type_id", name: "fk_person_attributes_2"
  add_foreign_key "person_birth_details", "birth_registration_type", primary_key: "birth_registration_type_id", name: "fk_person_birth_details_8"
  add_foreign_key "person_birth_details", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_birth_details_1"
  add_foreign_key "person_birth_details", "level_of_education", primary_key: "level_of_education_id", name: "fk_person_birth_details_4"
  add_foreign_key "person_birth_details", "location", column: "birth_location_id", primary_key: "location_id", name: "fk_person_birth_details_3"
  add_foreign_key "person_birth_details", "location", column: "location_created_at", primary_key: "location_id", name: "fk_person_birth_details_6"
  add_foreign_key "person_birth_details", "location", column: "place_of_birth", primary_key: "location_id", name: "fk_person_birth_details_2"
  add_foreign_key "person_birth_details", "mode_of_delivery", primary_key: "mode_of_delivery_id", name: "fk_person_birth_details_5"
  add_foreign_key "person_birth_details", "person_type_of_births", column: "type_of_birth", primary_key: "person_type_of_birth_id", name: "fk_person_birth_details_7"
  add_foreign_key "person_birth_details", "users", column: "creator", primary_key: "user_id", name: "fk_person_birth_details_9"
  add_foreign_key "person_name", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_name_1"
  add_foreign_key "person_name", "users", column: "voided_by", primary_key: "user_id", name: "fk_person_name_2"
  add_foreign_key "person_name_code", "person_name", primary_key: "person_name_id", name: "fk_person_name_code_1"
  add_foreign_key "person_record_statuses", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_record_statuses_1"
  add_foreign_key "person_record_statuses", "statuses", primary_key: "status_id", name: "fk_person_record_statuses_2"
  add_foreign_key "person_record_statuses", "users", column: "voided_by", primary_key: "user_id", name: "fk_person_record_statuses_3"
  add_foreign_key "person_relationship", "core_person", column: "person_a", primary_key: "person_id", name: "fk_person_relationship_1"
  add_foreign_key "person_relationship", "core_person", column: "person_b", primary_key: "person_id", name: "fk_person_relationship_2"
  add_foreign_key "person_relationship", "person_relationship_types", primary_key: "person_relationship_type_id", name: "fk_person_relationship_3"
  #add_foreign_key "potential_duplicates", "person", primary_key: "person_id", name: "fk_potential_duplicates_1"
  add_foreign_key "user_role", "role", primary_key: "role_id", name: "fk_user_role_2"
  add_foreign_key "user_role", "users", primary_key: "user_id", name: "fk_user_role_1"
  add_foreign_key "users", "core_person", column: "person_id", primary_key: "person_id", name: "fk_users_1"
  add_foreign_key "users", "users", column: "voided_by", primary_key: "user_id", name: "fk_users_2"
end
