# frozen_string_literal: true

module FlexcarPromotions
  class Cart < ApplicationRecord
    has_many :cart_items, dependent: :destroy
    has_many :items, through: :cart_items

    def add_item(item, quantity: nil, weight: nil)
      validate_item_unit!(item, quantity, weight)

      cart_item = cart_items.find_or_initialize_by(item: item)

      if item.sold_by_quantity?
        cart_item.quantity = (cart_item.quantity || 0) + quantity
      else
        cart_item.weight = (cart_item.weight || 0) + weight
      end

      cart_item.save!
      cart_item
    end

    def remove_item(item)
      cart_items.find_by(item: item)&.destroy
    end

    def calculate_total
      PricingService.new(self).calculate
    end

    def clear
      cart_items.destroy_all
    end

    private

    def validate_item_unit!(item, quantity, weight)
      if item.sold_by_quantity? && quantity.nil?
        raise ArgumentError, "Quantity required for #{item.name}"
      elsif item.sold_by_weight? && weight.nil?
        raise ArgumentError, "Weight required for #{item.name}"
      end
    end
  end
end
