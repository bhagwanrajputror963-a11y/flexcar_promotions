# frozen_string_literal: true

module FlexcarPromotions
  module Promotions
    class WeightThresholdCalculator < BaseCalculator
      def calculate
        return 0 unless item.sold_by_weight?
        return 0 unless cart_item.weight >= threshold_weight

        base_price * (promotion.value / 100.0)
      end

      private

      def threshold_weight
        @threshold_weight ||= promotion.config["threshold_weight"] || 0
      end
    end
  end
end
