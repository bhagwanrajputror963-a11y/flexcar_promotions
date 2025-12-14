# frozen_string_literal: true

class CreateFlexcarPromotionsPromotions < ActiveRecord::Migration[8.1]
  def change
    create_table :flexcar_promotions_promotions do |t|
      t.string :name, null: false, limit: 255
      t.string :promotion_type, null: false, limit: 50
      t.decimal :value, precision: 10, scale: 2
      t.string :target_type, null: false, limit: 50
      t.integer :target_id
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.text :config

      t.timestamps
    end

    add_index :flexcar_promotions_promotions, :promotion_type
    add_index :flexcar_promotions_promotions, [ :target_type, :target_id ], name: "index_promotions_on_target"
    add_index :flexcar_promotions_promotions, :start_time
    add_index :flexcar_promotions_promotions, :end_time
    add_index :flexcar_promotions_promotions, [ :start_time, :end_time ], name: "index_promotions_on_time_range"

    add_check_constraint :flexcar_promotions_promotions, "value >= 0", name: "value_non_negative"
    add_check_constraint :flexcar_promotions_promotions, "end_time IS NULL OR end_time > start_time", name: "valid_time_range"
    add_check_constraint :flexcar_promotions_promotions,
      "promotion_type IN ('flat_discount', 'percentage_discount', 'buy_x_get_y', 'weight_threshold')",
      name: "valid_promotion_type"
    add_check_constraint :flexcar_promotions_promotions,
      "target_type IN ('Item', 'Category')",
      name: "valid_target_type"
  end
end
