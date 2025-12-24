# frozen_string_literal: true

module FlexcarPromotions
  class Promotion < ApplicationRecord
        # Calculate the discount amount for a given cart_item
        def calculate_discount(cart_item)
          case promotion_type
          when "flat_discount"
            # Flat discount capped at base price
            base_price = cart_item.base_price
            [ value.to_f, base_price ].min
          when "percentage_discount"
            base = cart_item.base_price
            (base * value.to_f / 100.0).round(2)
          when "buy_x_get_y"
            buy_qty = config["buy_quantity"].to_i
            get_qty = config["get_quantity"].to_i
            discount_percent = config["discount_percent"].to_f
            if buy_qty > 0 && get_qty > 0 && discount_percent > 0
              eligible_sets = (cart_item.quantity.to_i / (buy_qty + get_qty))
              free_items = eligible_sets * get_qty
              free_items * cart_item.unit_price * (discount_percent / 100.0)
            else
              0
            end
          when "weight_threshold"
            threshold = config["threshold_weight"].to_f
            if cart_item.weight.to_f >= threshold
              base = cart_item.base_price
              (base * value.to_f / 100.0).round(2)
            else
              0
            end
          else
            0
          end
        end
    PROMOTION_TYPES = %w[flat_discount percentage_discount buy_x_get_y weight_threshold].freeze
    TARGET_TYPES = %w[Item Category].freeze

    # Normalize target_type to short form before validation
    before_validation :normalize_target_type

    validates :name, presence: true
    validates :promotion_type, presence: true, inclusion: { in: PROMOTION_TYPES }
    validates :target_type, presence: true, inclusion: { in: TARGET_TYPES }
    validates :start_time, presence: true
    validates :value, numericality: { greater_than: 0 }, if: -> { requires_value? }

    serialize :config, coder: JSON

    scope :active, -> { where("start_time <= ? AND (end_time IS NULL OR end_time >= ?)", Time.current, Time.current) }

    # Custom getter for polymorphic target that handles our shortened type names
    def target
      return nil unless target_type.present? && target_id.present?

      klass = "FlexcarPromotions::#{target_type}".constantize
      klass.find_by(id: target_id)
    end

    # Custom setter for polymorphic target
    def target=(record)
      if record.nil?
        self.target_type = nil
        self.target_id = nil
      else
        # Extract the class name and set normalized form
        self.target_type = record.class.name.demodulize
        self.target_id = record.id
      end
    end

    def active?
      start_time <= Time.current && (end_time.nil? || end_time >= Time.current)
    end

    def applies_to?(item)
      return false unless active?

      case target_type
      when "Item"
        item.id == target_id
      when "Category"
        # Handle both new polymorphic approach (category ID) and legacy config approach (category name)
        if target_id.present?
          # New approach: compare category IDs
          item.category&.id == target_id
        else
          # Legacy approach: compare category names
          category_name = if item.respond_to?(:category) && item.category.respond_to?(:name)
                            item.category.name
          else
                            item.category
          end
          category_name == config&.dig("category")
        end
      else
        false
      end
    end

    def target_id_value
      @target_id_value ||= target_id.presence || config&.dig("category")
    end

    private

    def requires_value?
      %w[flat_discount percentage_discount weight_threshold].include?(promotion_type)
    end

    def normalize_target_type
      return unless target_type.present?

      # Convert 'FlexcarPromotions::Item' -> 'Item', 'FlexcarPromotions::Category' -> 'Category'
      self.target_type = target_type.demodulize if target_type.include?("::")
    end
  end
end
