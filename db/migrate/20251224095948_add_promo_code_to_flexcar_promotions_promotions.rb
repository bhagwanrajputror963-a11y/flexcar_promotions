class AddPromoCodeToFlexcarPromotionsPromotions < ActiveRecord::Migration[8.1]
  def change
    add_column :flexcar_promotions_promotions, :promo_code, :string
    add_index :flexcar_promotions_promotions, :promo_code
  end
end
