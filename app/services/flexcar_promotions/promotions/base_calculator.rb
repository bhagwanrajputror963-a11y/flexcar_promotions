# frozen_string_literal: true

module FlexcarPromotions
  module Promotions
    class BaseCalculator
      attr_reader :cart_item, :promotion

      def initialize(cart_item, promotion)
        @cart_item = cart_item
        @promotion = promotion
      end

      def calculate
        raise NotImplementedError, "Subclasses must implement calculate method"
      end

      protected

      def item
        cart_item.item
      end

      def base_price
        cart_item.base_price
      end
    end
  end
end
