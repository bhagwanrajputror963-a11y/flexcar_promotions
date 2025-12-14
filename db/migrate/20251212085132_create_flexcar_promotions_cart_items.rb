# frozen_string_literal: true

class CreateFlexcarPromotionsCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :flexcar_promotions_cart_items do |t|
      t.references :cart, null: false, foreign_key: { to_table: :flexcar_promotions_carts, on_delete: :cascade }
      t.references :item, null: false, foreign_key: { to_table: :flexcar_promotions_items, on_delete: :restrict }
      t.decimal :quantity, precision: 10, scale: 2
      t.decimal :weight, precision: 10, scale: 2

      t.timestamps
    end

    add_index :flexcar_promotions_cart_items, [ :cart_id, :item_id ], unique: true, name: "index_cart_items_on_cart_and_item"

    add_check_constraint :flexcar_promotions_cart_items, "quantity > 0 OR weight > 0", name: "quantity_or_weight_positive"
    add_check_constraint :flexcar_promotions_cart_items, "NOT (quantity IS NOT NULL AND weight IS NOT NULL)", name: "quantity_or_weight_exclusive"
  end
end
