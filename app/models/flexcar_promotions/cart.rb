# frozen_string_literal: true

module FlexcarPromotions
  class Cart < ApplicationRecord
    has_many :cart_items, dependent: :destroy
    has_many :items, through: :cart_items

    serialize :applied_promotion_ids, coder: JSON

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

    def apply_promo_code(code)
      promotion = Promotion.find_by(promo_code: code)
      return { success: false, error: "Invalid promo code" } unless promotion
      return { success: false, error: "Promotion has expired" } unless promotion.active?

      if cart_items.empty?
        return { success: false, error: "Cannot apply a promo code to an empty cart" }
      end

      self.applied_promotion_ids ||= []
      if applied_promotion_ids.include?(promotion.id)
        return { success: false, error: "Promo code already applied" }
      end

      applied_promotion_ids << promotion.id
      save!
      { success: true, promotion: promotion }
    end

    def remove_promo_code(code)
      promotion = Promotion.find_by(promo_code: code)
      return { success: false, error: "Invalid promo code" } unless promotion

      self.applied_promotion_ids ||= []
      applied_promotion_ids.delete(promotion.id)
      save!
      { success: true }
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
