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

ActiveRecord::Schema.define(version: 20160426134033) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "asset_files", force: :cascade do |t|
    t.integer  "asset_id"
    t.string   "s3_bucket"
    t.text     "s3_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "slug"
    t.string   "source"
    t.text     "s3_url"
  end

  add_index "asset_files", ["asset_id"], name: "index_asset_files_on_asset_id", using: :btree
  add_index "asset_files", ["s3_bucket"], name: "index_asset_files_on_s3_bucket", using: :btree
  add_index "asset_files", ["s3_key"], name: "index_asset_files_on_s3_key", using: :btree
  add_index "asset_files", ["slug"], name: "index_asset_files_on_slug", using: :btree
  add_index "asset_files", ["source"], name: "index_asset_files_on_source", using: :btree

  create_table "assets", force: :cascade do |t|
    t.text     "label"
    t.text     "config"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "dc_id"
    t.boolean  "published"
    t.text     "body"
    t.text     "dc_data"
    t.text     "dc_published_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.text     "deck"
  end

  add_index "documents", ["dc_id"], name: "index_documents_on_dc_id", using: :btree
  add_index "documents", ["published"], name: "index_documents_on_published", using: :btree

  create_table "email_signups", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirm_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "q_work_in_criminal_justice"
    t.string   "q_is_journalist"
    t.string   "q_incarcerated"
    t.string   "email_format"
    t.string   "signup_source"
    t.text     "log_blob"
    t.string   "mailchimp_id"
    t.string   "mailchimp_euid"
    t.string   "mailchimp_leid"
    t.boolean  "mailchimp_is_active"
    t.text     "options_on_create"
    t.text     "mailchimp_data"
  end

  add_index "email_signups", ["confirm_token"], name: "index_email_signups_on_confirm_token", using: :btree
  add_index "email_signups", ["email"], name: "index_email_signups_on_email", using: :btree
  add_index "email_signups", ["mailchimp_euid"], name: "index_email_signups_on_mailchimp_euid", using: :btree
  add_index "email_signups", ["mailchimp_id"], name: "index_email_signups_on_mailchimp_id", using: :btree
  add_index "email_signups", ["mailchimp_is_active"], name: "index_email_signups_on_mailchimp_is_active", using: :btree
  add_index "email_signups", ["mailchimp_leid"], name: "index_email_signups_on_mailchimp_leid", using: :btree

  create_table "external_service_responses", force: :cascade do |t|
    t.string   "action"
    t.text     "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "external_service_responses", ["action"], name: "index_external_service_responses_on_action", using: :btree

  create_table "feature_flags", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_flags", ["key"], name: "index_feature_flags_on_key", using: :btree
  add_index "feature_flags", ["value"], name: "index_feature_flags_on_value", using: :btree

  create_table "featured_block_activate_events", force: :cascade do |t|
    t.integer  "featured_block_id"
    t.integer  "user_id"
    t.text     "snapshot"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_block_activate_events", ["created_at"], name: "index_featured_block_activate_events_on_created_at", using: :btree
  add_index "featured_block_activate_events", ["featured_block_id"], name: "index_featured_block_activate_events_on_featured_block_id", using: :btree
  add_index "featured_block_activate_events", ["user_id"], name: "index_featured_block_activate_events_on_user_id", using: :btree

  create_table "featured_blocks", force: :cascade do |t|
    t.string   "template"
    t.text     "slots"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_blocks", ["published"], name: "index_featured_blocks_on_published", using: :btree

  create_table "freeform_stream_promos", force: :cascade do |t|
    t.text     "slug"
    t.text     "html"
    t.datetime "revised_at"
    t.string   "deploy_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "published"
  end

  add_index "freeform_stream_promos", ["deploy_token"], name: "index_freeform_stream_promos_on_deploy_token", using: :btree
  add_index "freeform_stream_promos", ["published"], name: "index_freeform_stream_promos_on_published", using: :btree
  add_index "freeform_stream_promos", ["slug"], name: "index_freeform_stream_promos_on_slug", using: :btree

  create_table "graphics", force: :cascade do |t|
    t.string   "slug"
    t.text     "html"
    t.text     "head"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "deploy_token"
  end

  add_index "graphics", ["deploy_token"], name: "index_graphics_on_deploy_token", using: :btree
  add_index "graphics", ["slug"], name: "index_graphics_on_slug", using: :btree

  create_table "letters", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "twitter"
    t.text     "street_address"
    t.boolean  "is_anonymous"
    t.text     "content"
    t.integer  "post_id"
    t.string   "status"
    t.boolean  "stream_promo"
    t.text     "excerpt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "original_content"
    t.datetime "published_at"
  end

  add_index "letters", ["is_anonymous"], name: "index_letters_on_is_anonymous", using: :btree
  add_index "letters", ["post_id"], name: "index_letters_on_post_id", using: :btree
  add_index "letters", ["published_at"], name: "index_letters_on_published_at", using: :btree
  add_index "letters", ["status"], name: "index_letters_on_status", using: :btree

  create_table "link_decode_events", force: :cascade do |t|
    t.integer  "link_id"
    t.text     "cookies"
    t.string   "placement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "referer"
  end

  add_index "link_decode_events", ["link_id"], name: "index_link_decode_events_on_link_id", using: :btree

  create_table "link_reports", force: :cascade do |t|
    t.integer  "link_id"
    t.integer  "tag_id"
    t.integer  "user_id"
    t.text     "url"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "link_reports", ["link_id"], name: "index_link_reports_on_link_id", using: :btree
  add_index "link_reports", ["status"], name: "index_link_reports_on_status", using: :btree
  add_index "link_reports", ["tag_id"], name: "index_link_reports_on_tag_id", using: :btree
  add_index "link_reports", ["user_id"], name: "index_link_reports_on_user_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.text     "url"
    t.text     "title"
    t.integer  "creator_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain"
    t.boolean  "approved"
    t.text     "html"
    t.text     "fb_image_url"
    t.integer  "tweet_count"
    t.text     "email_content"
    t.integer  "facebook_count"
    t.boolean  "editors_pick"
    t.string   "html_url"
    t.integer  "photo_id"
    t.string   "short_token"
    t.text     "html_meta_json"
    t.boolean  "remote_is_alive"
  end

  add_index "links", ["approved"], name: "index_links_on_approved", using: :btree
  add_index "links", ["created_at"], name: "index_links_on_created_at", using: :btree
  add_index "links", ["creator_id"], name: "index_links_on_creator_id", using: :btree
  add_index "links", ["domain"], name: "index_links_on_domain", using: :btree
  add_index "links", ["editors_pick"], name: "index_links_on_editors_pick", using: :btree
  add_index "links", ["photo_id"], name: "index_links_on_photo_id", using: :btree
  add_index "links", ["remote_is_alive"], name: "index_links_on_remote_is_alive", using: :btree
  add_index "links", ["short_token"], name: "index_links_on_short_token", using: :btree
  add_index "links", ["url"], name: "index_links_on_url", using: :btree

  create_table "mailchimp_webhooks", force: :cascade do |t|
    t.string   "event_type"
    t.string   "email"
    t.text     "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "mailchimp_webhooks", ["email"], name: "index_mailchimp_webhooks_on_email", using: :btree
  add_index "mailchimp_webhooks", ["event_type"], name: "index_mailchimp_webhooks_on_event_type", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "token"
    t.datetime "last_seen_at"
    t.string   "last_ip"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "visits_from_ips"
  end

  add_index "members", ["active"], name: "index_members_on_active", using: :btree
  add_index "members", ["email"], name: "index_members_on_email", using: :btree
  add_index "members", ["token"], name: "index_members_on_token", using: :btree

  create_table "newsletter_assignments", force: :cascade do |t|
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.integer  "newsletter_id"
    t.integer  "position"
    t.string   "bucket"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "homepage_position"
  end

  add_index "newsletter_assignments", ["bucket"], name: "index_newsletter_assignments_on_bucket", using: :btree
  add_index "newsletter_assignments", ["homepage_position"], name: "index_newsletter_assignments_on_homepage_position", using: :btree
  add_index "newsletter_assignments", ["newsletter_id"], name: "index_newsletter_assignments_on_newsletter_id", using: :btree
  add_index "newsletter_assignments", ["taggable_id"], name: "index_newsletter_assignments_on_taggable_id", using: :btree
  add_index "newsletter_assignments", ["taggable_type"], name: "index_newsletter_assignments_on_taggable_type", using: :btree

  create_table "newsletters", force: :cascade do |t|
    t.string   "name"
    t.string   "email_subject"
    t.string   "mailchimp_id"
    t.text     "blurb"
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mailchimp_web_id"
    t.text     "byline"
    t.datetime "published_at"
    t.boolean  "public"
    t.string   "archive_url"
  end

  add_index "newsletters", ["public"], name: "index_newsletters_on_public", using: :btree
  add_index "newsletters", ["published_at"], name: "index_newsletters_on_published_at", using: :btree

  create_table "partner_pageviews", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "partner_id"
    t.text     "url"
    t.integer  "pageviews"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "partner_pageviews", ["partner_id"], name: "index_partner_pageviews_on_partner_id", using: :btree
  add_index "partner_pageviews", ["post_id"], name: "index_partner_pageviews_on_post_id", using: :btree

  create_table "partners", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "photos", force: :cascade do |t|
    t.text     "original_url"
    t.text     "caption"
    t.text     "byline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "random_slug"
    t.hstore   "sizes"
    t.boolean  "via_gator"
    t.decimal  "aspect_ratio"
  end

  add_index "photos", ["byline"], name: "index_photos_on_byline", using: :btree
  add_index "photos", ["caption"], name: "index_photos_on_caption", using: :btree
  add_index "photos", ["original_url"], name: "index_photos_on_original_url", using: :btree
  add_index "photos", ["random_slug"], name: "index_photos_on_random_slug", using: :btree
  add_index "photos", ["sizes"], name: "index_photos_on_sizes", using: :gin
  add_index "photos", ["via_gator"], name: "index_photos_on_via_gator", using: :btree

  create_table "post_delegate_paths", force: :cascade do |t|
    t.integer  "post_id"
    t.boolean  "active"
    t.text     "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "post_delegate_paths", ["active"], name: "index_post_delegate_paths_on_active", using: :btree
  add_index "post_delegate_paths", ["post_id"], name: "index_post_delegate_paths_on_post_id", using: :btree

  create_table "post_deploy_tokens", force: :cascade do |t|
    t.integer  "post_id"
    t.text     "label"
    t.text     "token"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "post_deploy_tokens", ["post_id"], name: "index_post_deploy_tokens_on_post_id", using: :btree

  create_table "post_embeds", force: :cascade do |t|
    t.string   "embed_type"
    t.integer  "embed_id"
    t.integer  "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "post_embeds", ["embed_id"], name: "index_post_embeds_on_embed_id", using: :btree
  add_index "post_embeds", ["embed_type"], name: "index_post_embeds_on_embed_type", using: :btree
  add_index "post_embeds", ["post_id"], name: "index_post_embeds_on_post_id", using: :btree

  create_table "post_formats", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_formats", ["name"], name: "index_post_formats_on_name", using: :btree
  add_index "post_formats", ["slug"], name: "index_post_formats_on_slug", using: :btree

  create_table "post_locks", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "acquired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_locks", ["acquired_at"], name: "index_post_locks_on_acquired_at", using: :btree
  add_index "post_locks", ["post_id"], name: "index_post_locks_on_post_id", using: :btree
  add_index "post_locks", ["user_id"], name: "index_post_locks_on_user_id", using: :btree

  create_table "post_published_events", force: :cascade do |t|
    t.integer  "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "post_published_events", ["post_id"], name: "index_post_published_events_on_post_id", using: :btree

  create_table "post_shareables", force: :cascade do |t|
    t.integer  "post_id"
    t.string   "slug"
    t.integer  "photo_id"
    t.text     "facebook_headline"
    t.text     "facebook_description"
    t.text     "twitter_headline"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "post_shareables", ["post_id"], name: "index_post_shareables_on_post_id", using: :btree
  add_index "post_shareables", ["slug"], name: "index_post_shareables_on_slug", using: :btree

  create_table "post_thread_assignments", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "post_thread_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_thread_assignments", ["post_id"], name: "index_post_thread_assignments_on_post_id", using: :btree
  add_index "post_thread_assignments", ["post_thread_id"], name: "index_post_thread_assignments_on_post_thread_id", using: :btree

  create_table "post_threads", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_threads", ["name"], name: "index_post_threads_on_name", using: :btree

  create_table "post_versions", force: :cascade do |t|
    t.integer  "post_id"
    t.boolean  "autosave"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_versions", ["autosave"], name: "index_post_versions_on_autosave", using: :btree
  add_index "post_versions", ["post_id"], name: "index_post_versions_on_post_id", using: :btree
  add_index "post_versions", ["user_id"], name: "index_post_versions_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "content"
    t.datetime "published_at"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.hstore   "redirects"
    t.string   "slug"
    t.string   "post_format"
    t.text     "email_content"
    t.text     "deck"
    t.text     "byline_freeform"
    t.string   "stream_promo"
    t.integer  "featured_photo_id"
    t.text     "facebook_headline"
    t.text     "twitter_headline"
    t.text     "produced_by"
    t.datetime "revised_at"
    t.integer  "lead_photo_id"
    t.text     "inject_html"
    t.text     "display_headline"
    t.text     "custom_scss"
    t.text     "freeform_post_header"
    t.text     "facebook_description"
    t.boolean  "in_stream"
  end

  add_index "posts", ["featured_photo_id"], name: "index_posts_on_featured_photo_id", using: :btree
  add_index "posts", ["in_stream"], name: "index_posts_on_in_stream", using: :btree
  add_index "posts", ["post_format"], name: "index_posts_on_post_format", using: :btree
  add_index "posts", ["published_at"], name: "index_posts_on_published_at", using: :btree
  add_index "posts", ["redirects"], name: "index_posts_on_redirects", using: :gin
  add_index "posts", ["revised_at"], name: "index_posts_on_revised_at", using: :btree
  add_index "posts", ["slug"], name: "index_posts_on_slug", using: :btree
  add_index "posts", ["status"], name: "index_posts_on_status", using: :btree
  add_index "posts", ["stream_promo"], name: "index_posts_on_stream_promo", using: :btree
  add_index "posts", ["title"], name: "index_posts_on_title", using: :btree

  create_table "public_search_queries", force: :cascade do |t|
    t.text     "query"
    t.string   "token"
    t.text     "referer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "search_results"
    t.integer  "user_id"
  end

  add_index "public_search_queries", ["query"], name: "index_public_search_queries_on_query", using: :btree
  add_index "public_search_queries", ["token"], name: "index_public_search_queries_on_token", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.string   "resource_type"
    t.integer  "resource_id"
    t.integer  "rating"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["resource_id"], name: "index_ratings_on_resource_id", using: :btree
  add_index "ratings", ["resource_type"], name: "index_ratings_on_resource_type", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "static_pages", force: :cascade do |t|
    t.string   "slug"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.text     "description"
    t.text     "page_title"
  end

  add_index "static_pages", ["slug"], name: "index_static_pages_on_slug", using: :btree

  create_table "stripe_customers", force: :cascade do |t|
    t.string   "stripe_customer_id"
    t.string   "email"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "amount"
    t.string   "custom_amount"
    t.string   "plan"
    t.string   "donation_type"
    t.string   "phone"
    t.string   "inbound_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "stripe_customers", ["email"], name: "index_stripe_customers_on_email", using: :btree
  add_index "stripe_customers", ["stripe_customer_id"], name: "index_stripe_customers_on_stripe_customer_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content"
    t.integer  "user_id"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["user_id"], name: "index_taggings_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag_type"
    t.boolean  "public"
    t.integer  "featured_photo_id"
    t.text     "content"
    t.text     "sidebar_description"
    t.text     "collection_summary"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree
  add_index "tags", ["public"], name: "index_tags_on_public", using: :btree
  add_index "tags", ["slug"], name: "index_tags_on_slug", using: :btree
  add_index "tags", ["tag_type"], name: "index_tags_on_tag_type", using: :btree

  create_table "user_post_assignments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
  end

  add_index "user_post_assignments", ["position"], name: "index_user_post_assignments_on_position", using: :btree
  add_index "user_post_assignments", ["post_id"], name: "index_user_post_assignments_on_post_id", using: :btree
  add_index "user_post_assignments", ["source"], name: "index_user_post_assignments_on_source", using: :btree
  add_index "user_post_assignments", ["user_id"], name: "index_user_post_assignments_on_user_id", using: :btree

  create_table "user_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "events"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_sessions", ["user_id"], name: "index_user_sessions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "twitter"
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bookmarklet_token"
    t.string   "login_token"
    t.datetime "login_token_expires"
    t.string   "deploy_api_key"
    t.string   "slug"
    t.string   "name"
    t.text     "public_key"
    t.string   "phone"
    t.string   "title"
    t.datetime "last_seen"
  end

  add_index "users", ["bookmarklet_token"], name: "index_users_on_bookmarklet_token", using: :btree
  add_index "users", ["deploy_api_key"], name: "index_users_on_deploy_api_key", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["login_token"], name: "index_users_on_login_token", using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", using: :btree
  add_index "users", ["twitter"], name: "index_users_on_twitter", using: :btree

  create_table "weekly_newsletter_assignments", force: :cascade do |t|
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.integer  "weekly_newsletter_id"
    t.integer  "position"
    t.string   "bucket"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "weekly_newsletter_assignments", ["bucket"], name: "index_weekly_newsletter_assignments_on_bucket", using: :btree
  add_index "weekly_newsletter_assignments", ["position"], name: "index_weekly_newsletter_assignments_on_position", using: :btree
  add_index "weekly_newsletter_assignments", ["taggable_id"], name: "index_weekly_newsletter_assignments_on_taggable_id", using: :btree
  add_index "weekly_newsletter_assignments", ["taggable_type"], name: "index_weekly_newsletter_assignments_on_taggable_type", using: :btree
  add_index "weekly_newsletter_assignments", ["weekly_newsletter_id"], name: "index_weekly_newsletter_assignments_on_weekly_newsletter_id", using: :btree

  create_table "weekly_newsletters", force: :cascade do |t|
    t.string   "name"
    t.text     "email_subject"
    t.string   "mailchimp_id"
    t.string   "mailchimp_web_id"
    t.text     "byline"
    t.datetime "published_at"
    t.boolean  "public"
    t.text     "archive_url"
    t.text     "opening_graf"
    t.text     "quote_graf"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "tmp_stories"
    t.text     "other_stories"
  end

  add_index "weekly_newsletters", ["mailchimp_id"], name: "index_weekly_newsletters_on_mailchimp_id", using: :btree
  add_index "weekly_newsletters", ["mailchimp_web_id"], name: "index_weekly_newsletters_on_mailchimp_web_id", using: :btree
  add_index "weekly_newsletters", ["public"], name: "index_weekly_newsletters_on_public", using: :btree
  add_index "weekly_newsletters", ["published_at"], name: "index_weekly_newsletters_on_published_at", using: :btree

  create_table "yahoo_posts", force: :cascade do |t|
    t.integer  "post_id"
    t.text     "title"
    t.boolean  "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "lead_photo"
    t.text     "summary"
  end

  add_index "yahoo_posts", ["post_id"], name: "index_yahoo_posts_on_post_id", using: :btree
  add_index "yahoo_posts", ["published"], name: "index_yahoo_posts_on_published", using: :btree

end
