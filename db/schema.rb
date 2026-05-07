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

ActiveRecord::Schema[8.1].define(version: 2026_05_07_131232) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "attachments", force: :cascade do |t|
    t.bigint "comment_id"
    t.datetime "created_at", null: false
    t.string "file_name", null: false
    t.string "file_path", null: false
    t.bigint "file_size"
    t.string "mime_type"
    t.bigint "ticket_id"
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_user_id", null: false
    t.index ["comment_id"], name: "index_attachments_on_comment_id"
    t.index ["ticket_id"], name: "index_attachments_on_ticket_id"
    t.index ["uploaded_by_user_id"], name: "index_attachments_on_uploaded_by_user_id"
    t.check_constraint "ticket_id IS NOT NULL AND comment_id IS NULL OR ticket_id IS NULL AND comment_id IS NOT NULL", name: "attachments_ticket"
  end

  create_table "comments", force: :cascade do |t|
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "project_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["project_id", "user_id"], name: "index_project_members_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_members_on_project_id"
    t.index ["user_id"], name: "index_project_members_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_projects_on_created_by_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "assigned_to_user_id"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id", null: false
    t.text "description"
    t.date "due_date"
    t.string "priority", default: "medium", null: false
    t.bigint "project_id", null: false
    t.string "status", default: "open", null: false
    t.integer "ticket_no", null: false
    t.string "ticket_type", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_user_id"], name: "index_tickets_on_assigned_to_user_id"
    t.index ["created_by_user_id"], name: "index_tickets_on_created_by_user_id"
    t.index ["project_id", "ticket_no"], name: "index_tickets_on_project_id_and_ticket_no", unique: true
    t.index ["project_id"], name: "index_tickets_on_project_id"
    t.check_constraint "priority::text = ANY (ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying, 'urgent'::character varying]::text[])", name: "ticket_priority"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying, 'in_progress'::character varying, 'resolved'::character varying, 'closed'::character varying]::text[])", name: "ticket_status"
    t.check_constraint "ticket_type::text = ANY (ARRAY['bug'::character varying, 'feature'::character varying, 'task'::character varying]::text[])", name: "ticket_type"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", null: false
    t.string "update_project"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role::text = ANY (ARRAY['manager'::character varying::text, 'developer'::character varying::text, 'qa'::character varying::text])", name: "user_role"
  end

  add_foreign_key "attachments", "comments"
  add_foreign_key "attachments", "tickets"
  add_foreign_key "attachments", "users", column: "uploaded_by_user_id"
  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "project_members", "projects"
  add_foreign_key "project_members", "users"
  add_foreign_key "projects", "users", column: "created_by_user_id"
  add_foreign_key "tickets", "projects"
  add_foreign_key "tickets", "users", column: "assigned_to_user_id"
  add_foreign_key "tickets", "users", column: "created_by_user_id"
end
