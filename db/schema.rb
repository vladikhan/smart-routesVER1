# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_10_27_083742) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "item_type"
    t.integer "item_id"
    t.string "collection_name"
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.string "name_en"
    t.string "region"
    t.text "description"
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "commentable_type"
    t.integer "commentable_id"
    t.text "text"
    t.integer "parent_id"
    t.boolean "is_flagged"
    t.boolean "is_hidden_by_admin"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "districts", force: :cascade do |t|
    t.bigint "city_id", null: false
    t.string "name"
    t.string "name_en"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["city_id"], name: "index_districts_on_city_id"
  end

  create_table "dm_messages", force: :cascade do |t|
    t.bigint "dm_room_id", null: false
    t.bigint "user_id", null: false
    t.text "message"
    t.boolean "is_read"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dm_room_id"], name: "index_dm_messages_on_dm_room_id"
    t.index ["user_id"], name: "index_dm_messages_on_user_id"
  end

  create_table "dm_rooms", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["receiver_id"], name: "index_dm_rooms_on_receiver_id"
    t.index ["sender_id"], name: "index_dm_rooms_on_sender_id"
  end

  create_table "entity_tags", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.string "entity_type"
    t.integer "entity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag_id"], name: "index_entity_tags_on_tag_id"
  end

  create_table "followers", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "following_id"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "likeable_type"
    t.integer "likeable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "actor_id", null: false
    t.string "notification_type"
    t.string "entity_type"
    t.integer "entity_id"
    t.boolean "is_read"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "place_owners", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "venue_id", null: false
    t.string "role"
    t.string "status"
    t.datetime "verified_at"
    t.integer "verified_by"
    t.string "business_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "verification_document_url"
    t.text "verification_notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_place_owners_on_user_id"
    t.index ["venue_id"], name: "index_place_owners_on_venue_id"
  end

  create_table "popularity_metrics", force: :cascade do |t|
    t.string "entity_type"
    t.integer "entity_id"
    t.integer "view_count"
    t.integer "like_count"
    t.integer "save_count"
    t.integer "comment_count"
    t.integer "share_count"
    t.integer "download_count"
    t.integer "completion_count"
    t.float "popularity_score"
    t.float "trending_score"
    t.integer "daily_views"
    t.integer "weekly_views"
    t.integer "monthly_views"
    t.datetime "last_calculated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "review_images", force: :cascade do |t|
    t.bigint "review_id", null: false
    t.string "image_url"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["review_id"], name: "index_review_images_on_review_id"
  end

  create_table "review_responses", force: :cascade do |t|
    t.bigint "review_id", null: false
    t.bigint "user_id", null: false
    t.text "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["review_id"], name: "index_review_responses_on_review_id"
    t.index ["user_id"], name: "index_review_responses_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "reviewable_type"
    t.integer "reviewable_id"
    t.text "text"
    t.decimal "total_score"
    t.boolean "is_flagged"
    t.datetime "flagged_at"
    t.integer "flagged_by"
    t.boolean "is_hidden_by_admin"
    t.integer "likes_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "route_items", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.string "item_type"
    t.integer "item_id"
    t.integer "position"
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["route_id"], name: "index_route_items_on_route_id"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "description"
    t.boolean "is_public"
    t.integer "view_count"
    t.integer "download_count"
    t.integer "completion_count"
    t.float "popularity_score"
    t.boolean "is_featured"
    t.integer "featured_order"
    t.integer "estimated_duration"
    t.integer "estimated_cost"
    t.string "difficulty_level"
    t.boolean "is_deleted"
    t.integer "likes_count"
    t.integer "reviews_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "average_rating", default: 0.0
    t.index ["user_id"], name: "index_routes_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "parameter"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.text "bio"
    t.string "image_url"
    t.string "location"
    t.string "budget_min"
    t.integer "budget_max"
    t.boolean "is_admin"
    t.boolean "is_banned"
    t.datetime "banned_at"
    t.integer "banned_by"
    t.text "ban_reason"
    t.boolean "email_verified"
    t.string "phone"
    t.boolean "is_online"
    t.datetime "last_seen_at"
    t.string "langauge"
    t.string "timezone"
    t.string "date_format"
    t.datetime "username_last_changed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "venues", force: :cascade do |t|
    t.bigint "district_id", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.string "venue_type"
    t.string "address"
    t.text "description"
    t.string "cuisine_type"
    t.string "price_range"
    t.decimal "geo_lat"
    t.decimal "geo_lng"
    t.string "phone"
    t.string "website"
    t.text "business_hours"
    t.integer "view_count"
    t.integer "save_count"
    t.float "popularity_score"
    t.boolean "is_featured"
    t.integer "featured_order"
    t.boolean "is_claimed"
    t.datetime "claimed_at"
    t.boolean "verified_business"
    t.string "status"
    t.integer "reviews_count"
    t.integer "likes_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "average_rating", default: 0.0
    t.index ["district_id"], name: "index_venues_on_district_id"
    t.index ["user_id"], name: "index_venues_on_user_id"
  end

  add_foreign_key "bookmarks", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "districts", "cities"
  add_foreign_key "dm_messages", "dm_rooms"
  add_foreign_key "dm_messages", "users"
  add_foreign_key "dm_rooms", "users", column: "receiver_id"
  add_foreign_key "dm_rooms", "users", column: "sender_id"
  add_foreign_key "entity_tags", "tags"
  add_foreign_key "likes", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "place_owners", "users"
  add_foreign_key "place_owners", "venues"
  add_foreign_key "review_images", "reviews"
  add_foreign_key "review_responses", "reviews"
  add_foreign_key "review_responses", "users"
  add_foreign_key "reviews", "users"
  add_foreign_key "route_items", "routes"
  add_foreign_key "routes", "users"
  add_foreign_key "venues", "districts"
  add_foreign_key "venues", "users"
end
