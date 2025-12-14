class CreateFlexcarPromotionsCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :flexcar_promotions_categories do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :flexcar_promotions_categories, :name, unique: true
  end
end
