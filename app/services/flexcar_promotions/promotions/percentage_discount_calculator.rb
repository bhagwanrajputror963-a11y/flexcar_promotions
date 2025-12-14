# frozen_string_literal: true

module FlexcarPromotions
  module Promotions
    class PercentageDiscountCalculator < BaseCalculator
      def calculate
        base_price * (promotion.value / 100.0)
      end
    end
  end
end
