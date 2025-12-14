# frozen_string_literal: true

module FlexcarPromotions
  module Promotions
    class FlatDiscountCalculator < BaseCalculator
      def calculate
        [ promotion.value, base_price ].min
      end
    end
  end
end
