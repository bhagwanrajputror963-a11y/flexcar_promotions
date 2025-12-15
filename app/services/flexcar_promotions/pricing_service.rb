# frozen_string_literal: true

module FlexcarPromotions
  class PricingService
    attr_reader :cart

    def initialize(cart)
      @cart = cart
    end

    def calculate
      result = {
        items: [],
        subtotal: 0,
        total_discount: 0,
        total: 0
      }

      used_promotions = Set.new
      # Cache active promotions for this calculation
      @active_promotions = Promotion.active.to_a
      # Cache applicable promotions per item_id for this calculation
      @applicable_promo_cache = {}

      cart.cart_items.includes(item: [:category, :brand]).each do |cart_item|
        item_result = calculate_item_price(cart_item, used_promotions)
        result[:items] << item_result
        result[:subtotal] += item_result[:base_price]
        result[:total_discount] += item_result[:discount]
      end

      result[:total] = result[:subtotal] - result[:total_discount]
      result
    end

    private

    def calculate_item_price(cart_item, used_promotions)
      base_price = cart_item.base_price
      best_promotion = find_best_promotion(cart_item, used_promotions)

      discount = if best_promotion
                   calculate_discount(cart_item, best_promotion)
      else
                   0
      end

      used_promotions.add(best_promotion) if best_promotion && !used_promotions.include?(best_promotion)

      {
        item_id: cart_item.item_id,
        item_name: cart_item.item.name,
        quantity: cart_item.quantity,
        weight: cart_item.weight,
        base_price: base_price,
        discount: discount,
        final_price: base_price - discount,
        promotion: best_promotion&.name
      }
    end

    def find_best_promotion(cart_item, used_promotions)
      # Use cached applicable promotions for this item if available
      item_id = cart_item.item_id
      @applicable_promo_cache[item_id] ||= @active_promotions.select { |promotion| promotion.applies_to?(cart_item.item) }
      applicable_promotions = @applicable_promo_cache[item_id].reject { |promotion| used_promotions.include?(promotion) }

      return nil if applicable_promotions.empty?

      applicable_promotions.max_by do |promotion|
        calculate_discount(cart_item, promotion)
      end
    end

    def calculate_discount(cart_item, promotion)
      calculator_class = promotion_calculator_class(promotion.promotion_type)
      calculator_class.new(cart_item, promotion).calculate
    end

    def promotion_calculator_class(promotion_type)
      case promotion_type
      when "flat_discount"
        Promotions::FlatDiscountCalculator
      when "percentage_discount"
        Promotions::PercentageDiscountCalculator
      when "buy_x_get_y"
        Promotions::BuyXGetYCalculator
      when "weight_threshold"
        Promotions::WeightThresholdCalculator
      else
        raise ArgumentError, "Unknown promotion type: #{promotion_type}"
      end
    end
  end
end
