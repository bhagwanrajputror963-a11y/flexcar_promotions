class AddInventoryToFlexcarPromotionsItems < ActiveRecord::Migration[8.1]
  def change
    add_column :flexcar_promotions_items, :stock_quantity, :integer, default: 0, null: false
    add_check_constraint :flexcar_promotions_items, 'stock_quantity >= 0', name: 'stock_quantity_non_negative'
  end
end
