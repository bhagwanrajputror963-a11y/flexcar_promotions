# frozen_string_literal: true

module FlexcarPromotions
  class CartItem < ApplicationRecord
    belongs_to :cart
    belongs_to :item

    validates :quantity, numericality: { greater_than: 0 }, if: -> { item&.sold_by_quantity? }
    validates :weight, numericality: { greater_than: 0 }, if: -> { item&.sold_by_weight? }

    def base_price
      if item.sold_by_quantity?
        item.price * quantity
      else
        item.price * weight
      end
    end

    def amount
      quantity || weight
    end
  end
end
