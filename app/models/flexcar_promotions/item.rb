# frozen_string_literal: true

module FlexcarPromotions
  class Item < ApplicationRecord
    SALE_UNITS = %w[quantity weight].freeze

    # Lightweight defaults to avoid cross-validation interference in tests
    attribute :name, :string, default: "Item"
    attribute :price, :decimal, default: 1.0
    attribute :sale_unit, :string, default: "quantity"

    validates :name, presence: true
    validates :price, presence: true, numericality: { greater_than: 0 }
    validates :sale_unit, presence: true, inclusion: { in: SALE_UNITS }
    validates :category, presence: true
    validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    has_many :cart_items, dependent: :destroy
    # Normalized associations (do not shadow legacy string attributes)
    belongs_to :brand, class_name: "FlexcarPromotions::Brand", foreign_key: :brand_id, optional: true
    belongs_to :category, class_name: "FlexcarPromotions::Category", foreign_key: :category_id, optional: true

    # Accept strings for association writers for backward compatibility in specs/factories
    def category=(value)
      if value.is_a?(FlexcarPromotions::Category) || value.nil?
        super(value)
      else
        super(FlexcarPromotions::Category.find_or_create_by(name: value))
      end
    end

    def brand=(value)
      if value.is_a?(FlexcarPromotions::Brand) || value.nil?
        super(value)
      else
        super(FlexcarPromotions::Brand.find_or_create_by(name: value))
      end
    end

    def sold_by_weight?
      sale_unit == "weight"
    end

    def sold_by_quantity?
      sale_unit == "quantity"
    end

    def in_stock?(quantity_or_weight = 1)
      return true if stock_quantity.nil? # Unlimited stock if not set
      return stock_quantity > 0 if sold_by_quantity?

      # For weight-based items, we assume stock_quantity represents grams
      stock_quantity >= quantity_or_weight
    end

    def available_stock
      stock_quantity || Float::INFINITY
    end
  end
end
