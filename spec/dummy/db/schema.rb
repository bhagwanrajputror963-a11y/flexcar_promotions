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

ActiveRecord::Schema[8.1].define(version: 2025_12_24_102139) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "flexcar_promotions_brands", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_flexcar_promotions_brands_on_name", unique: true
  end

  create_table "flexcar_promotions_cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "item_id", null: false
    t.decimal "quantity", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 10, scale: 2
    t.index ["cart_id", "item_id"], name: "index_flexcar_promotions_cart_items_on_cart_id_and_item_id", unique: true
    t.index ["cart_id"], name: "index_flexcar_promotions_cart_items_on_cart_id"
    t.index ["item_id"], name: "index_flexcar_promotions_cart_items_on_item_id"
  end

  create_table "flexcar_promotions_carts", force: :cascade do |t|
    t.text "applied_promotion_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flexcar_promotions_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_flexcar_promotions_categories_on_name", unique: true
  end

  create_table "flexcar_promotions_items", force: :cascade do |t|
    t.bigint "brand_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "sale_unit", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_flexcar_promotions_items_on_brand_id"
    t.index ["category_id"], name: "index_flexcar_promotions_items_on_category_id"
    t.check_constraint "stock_quantity >= 0", name: "stock_quantity_non_negative"
  end

  create_table "flexcar_promotions_promotions", force: :cascade do |t|
    t.text "config"
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.string "name", null: false
    t.string "promo_code"
    t.string "promotion_type", null: false
    t.datetime "start_time", null: false
    t.integer "target_id"
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 10, scale: 2
    t.index ["end_time"], name: "index_flexcar_promotions_promotions_on_end_time"
    t.index ["promo_code"], name: "index_flexcar_promotions_promotions_on_promo_code"
    t.index ["promotion_type"], name: "index_flexcar_promotions_promotions_on_promotion_type"
    t.index ["start_time"], name: "index_flexcar_promotions_promotions_on_start_time"
    t.index ["target_type", "target_id"], name: "idx_on_target_type_target_id_200cfb82f8"
  end

  add_foreign_key "flexcar_promotions_cart_items", "flexcar_promotions_carts", column: "cart_id"
  add_foreign_key "flexcar_promotions_cart_items", "flexcar_promotions_items", column: "item_id"
  add_foreign_key "flexcar_promotions_items", "flexcar_promotions_brands", column: "brand_id"
  add_foreign_key "flexcar_promotions_items", "flexcar_promotions_categories", column: "category_id"
end
