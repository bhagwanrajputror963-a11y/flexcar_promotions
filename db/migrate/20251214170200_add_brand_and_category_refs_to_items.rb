class AddBrandAndCategoryRefsToItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :flexcar_promotions_items, :brand, null: true, index: true, foreign_key: { to_table: :flexcar_promotions_brands }
    add_reference :flexcar_promotions_items, :category, null: true, index: true, foreign_key: { to_table: :flexcar_promotions_categories }
  end
end
