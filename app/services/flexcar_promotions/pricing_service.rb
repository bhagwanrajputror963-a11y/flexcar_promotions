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

      cart.cart_items.includes(item: [ :category, :brand ]).each do |cart_item|
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

      # Only consider manually applied promotions from the cart
      cart = cart_item.cart
      applied_promotion_ids = cart.applied_promotion_ids || []

      manually_applied_promotions = @active_promotions.select do |promo|
        applied_promotion_ids.include?(promo.id)
      end

      # Find the best applicable promotion from manually applied ones
      best_promotion = nil
      discount = 0

      manually_applied_promotions.each do |promotion|
        next unless promotion.applies_to?(cart_item.item)
        next if promotion.target_type == "Item" && used_promotions.include?(promotion.id)

        promo_discount = promotion.calculate_discount(cart_item)
        if promo_discount > discount
          discount = promo_discount
          best_promotion = promotion
        end
      end

      # Mark item-level promotions as used
      if best_promotion && best_promotion.target_type == "Item"
        used_promotions << best_promotion.id
      end

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

      # Only exclude item-specific promotions that have been used
      # Category/Brand level promotions can be reused across multiple items
      applicable_promotions = @applicable_promo_cache[item_id].reject do |promotion|
        used_promotions.include?(promotion) && promotion.target_type == "Item"
      end

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
