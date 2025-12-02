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

ActiveRecord::Schema.define(version: 2025_12_02_024702) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "collection_name"
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_type", "item_id"], name: "index_bookmarks_on_item_type_and_item_id"
    t.index ["user_id", "item_type", "item_id"], name: "index_bookmarks_unique", unique: true
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
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.text "text", null: false
    t.integer "parent_id"
    t.boolean "is_flagged", default: false
    t.boolean "is_hidden_by_admin", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
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
    t.text "message", null: false
    t.boolean "is_read", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dm_room_id"], name: "index_dm_messages_on_dm_room_id"
    t.index ["is_read"], name: "index_dm_messages_on_is_read"
    t.index ["user_id"], name: "index_dm_messages_on_user_id"
  end

  create_table "dm_rooms", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["receiver_id"], name: "index_dm_rooms_on_receiver_id"
    t.index ["sender_id", "receiver_id"], name: "index_dm_rooms_on_sender_id_and_receiver_id", unique: true
    t.index ["sender_id"], name: "index_dm_rooms_on_sender_id"
  end

  create_table "entity_tags", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.string "entity_type", null: false
    t.integer "entity_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entity_type", "entity_id"], name: "index_entity_tags_on_entity_type_and_entity_id"
    t.index ["tag_id", "entity_type", "entity_id"], name: "index_entity_tags_unique", unique: true
    t.index ["tag_id"], name: "index_entity_tags_on_tag_id"
  end

  create_table "followers", force: :cascade do |t|
    t.integer "follower_id", null: false
    t.integer "following_id", null: false
    t.string "status", default: "pending"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["follower_id", "following_id"], name: "index_followers_on_follower_id_and_following_id", unique: true
    t.index ["follower_id"], name: "index_followers_on_follower_id"
    t.index ["following_id"], name: "index_followers_on_following_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "likeable_type", null: false
    t.integer "likeable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
    t.index ["user_id", "likeable_type", "likeable_id"], name: "index_likes_on_user_and_likeable", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "actor_id", null: false
    t.string "notification_type", null: false
    t.string "entity_type"
    t.integer "entity_id"
    t.boolean "is_read", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["entity_type", "entity_id"], name: "index_notifications_on_entity_type_and_entity_id"
    t.index ["is_read"], name: "index_notifications_on_is_read"
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
    t.string "reviewable_type", null: false
    t.integer "reviewable_id", null: false
    t.text "text", null: false
    t.decimal "total_score", precision: 3, scale: 2, null: false
    t.boolean "is_flagged", default: false
    t.datetime "flagged_at"
    t.integer "flagged_by"
    t.boolean "is_hidden_by_admin", default: false
    t.integer "likes_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["is_flagged"], name: "index_reviews_on_is_flagged"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable_type_and_reviewable_id"
    t.index ["total_score"], name: "index_reviews_on_total_score"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "route_items", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "position", null: false
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "venue_id"
    t.integer "duration_minutes"
    t.index ["item_type", "item_id"], name: "index_route_items_on_item_type_and_item_id"
    t.index ["route_id", "position"], name: "index_route_items_on_route_id_and_position", unique: true
    t.index ["route_id"], name: "index_route_items_on_route_id"
    t.index ["venue_id"], name: "index_route_items_on_venue_id"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "is_public", default: true
    t.integer "view_count", default: 0
    t.integer "download_count", default: 0
    t.integer "completion_count", default: 0
    t.float "popularity_score", default: 0.0
    t.boolean "is_featured", default: false
    t.integer "featured_order"
    t.integer "estimated_duration"
    t.integer "estimated_cost"
    t.string "difficulty_level"
    t.boolean "is_deleted", default: false
    t.integer "likes_count", default: 0
    t.integer "reviews_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "average_rating", default: 0.0
    t.integer "bookmarks_count", default: 0, null: false
    t.text "tags"
    t.index ["is_deleted"], name: "index_routes_on_is_deleted"
    t.index ["is_featured"], name: "index_routes_on_is_featured"
    t.index ["is_public"], name: "index_routes_on_is_public"
    t.index ["popularity_score"], name: "index_routes_on_popularity_score"
    t.index ["user_id"], name: "index_routes_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "parameter"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.text "bio"
    t.string "image_url"
    t.string "location"
    t.string "budget_min"
    t.integer "budget_max"
    t.boolean "is_admin", default: false
    t.boolean "is_banned", default: false
    t.datetime "banned_at"
    t.integer "banned_by"
    t.text "ban_reason"
    t.boolean "email_verified", default: false
    t.string "phone"
    t.boolean "is_online", default: false
    t.datetime "last_seen_at"
    t.string "langauge", default: "ja"
    t.string "timezone", default: "Asia/Tokyo"
    t.string "date_format"
    t.datetime "username_last_changed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "verification_code"
    t.datetime "verification_code_sent_at"
    t.string "avatar"
    t.date "birthday"
    t.string "gender"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_admin"], name: "index_users_on_is_admin"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["verification_code"], name: "index_users_on_verification_code"
  end

  create_table "venues", force: :cascade do |t|
    t.bigint "district_id", null: false
    t.bigint "user_id"
    t.string "name", null: false
    t.string "venue_type", null: false
    t.string "address"
    t.text "description"
    t.string "cuisine_type"
    t.string "price_range"
    t.decimal "geo_lat", precision: 10, scale: 6
    t.decimal "geo_lng", precision: 10, scale: 6
    t.string "phone"
    t.string "website"
    t.text "business_hours"
    t.integer "view_count", default: 0
    t.integer "save_count", default: 0
    t.float "popularity_score", default: 0.0
    t.boolean "is_featured", default: false
    t.integer "featured_order"
    t.boolean "is_claimed", default: false
    t.datetime "claimed_at"
    t.boolean "verified_business", default: false
    t.string "status", default: "pending"
    t.integer "reviews_count", default: 0
    t.integer "likes_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "average_rating", default: 0.0
    t.decimal "latitude", precision: 10, scale: 6
    t.index ["district_id"], name: "index_venues_on_district_id"
    t.index ["geo_lat", "geo_lng"], name: "index_venues_on_geo_lat_and_geo_lng"
    t.index ["is_featured"], name: "index_venues_on_is_featured"
    t.index ["name"], name: "index_venues_on_name"
    t.index ["popularity_score"], name: "index_venues_on_popularity_score"
    t.index ["status"], name: "index_venues_on_status"
    t.index ["user_id"], name: "index_venues_on_user_id"
    t.index ["venue_type"], name: "index_venues_on_venue_type"
  end

  add_foreign_key "bookmarks", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "districts", "cities"
  add_foreign_key "dm_messages", "dm_rooms"
  add_foreign_key "dm_messages", "users"
  add_foreign_key "dm_rooms", "users", column: "receiver_id"
  add_foreign_key "dm_rooms", "users", column: "sender_id"
  add_foreign_key "entity_tags", "tags"
  add_foreign_key "followers", "users", column: "follower_id"
  add_foreign_key "followers", "users", column: "following_id"
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
  add_foreign_key "route_items", "venues"
  add_foreign_key "routes", "users"
  add_foreign_key "venues", "districts"
  add_foreign_key "venues", "users"
end
