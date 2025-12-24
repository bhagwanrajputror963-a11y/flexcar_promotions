class AddAppliedPromotionIdsToCart < ActiveRecord::Migration[8.1]
  def change
    add_column :flexcar_promotions_carts, :applied_promotion_ids, :text
  end
end
