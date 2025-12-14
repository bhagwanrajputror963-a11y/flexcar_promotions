# frozen_string_literal: true

module FlexcarPromotions
  module Promotions
    class BuyXGetYCalculator < BaseCalculator
      def calculate
        return 0 unless item.sold_by_quantity?
        return 0 unless cart_item.quantity >= required_quantity

        free_items = (cart_item.quantity / required_quantity).floor * free_quantity
        discount_percentage = discount_percent / 100.0

        item.price * free_items * discount_percentage
      end

      private

      def required_quantity
        @required_quantity ||= promotion.config["buy_quantity"] || 1
      end

      def free_quantity
        @free_quantity ||= promotion.config["get_quantity"] || 1
      end

      def discount_percent
        @discount_percent ||= promotion.config["discount_percent"] || 100
      end
    end
  end
end
