# frozen_string_literal: true

class CreateFlexcarPromotionsItems < ActiveRecord::Migration[8.1]
  def change
    create_table :flexcar_promotions_items do |t|
      t.string :name, null: false, limit: 255
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :sale_unit, null: false, limit: 20

      t.timestamps
    end

    add_index :flexcar_promotions_items, :sale_unit

    add_check_constraint :flexcar_promotions_items, "price > 0", name: "price_positive"
    add_check_constraint :flexcar_promotions_items, "sale_unit IN ('quantity', 'weight')", name: "valid_sale_unit"
  end
end
