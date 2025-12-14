# frozen_string_literal: true

module FlexcarPromotions
  class Promotion < ApplicationRecord
    PROMOTION_TYPES = %w[flat_discount percentage_discount buy_x_get_y weight_threshold].freeze
    TARGET_TYPES = %w[Item Category].freeze

    validates :name, presence: true
    validates :promotion_type, presence: true, inclusion: { in: PROMOTION_TYPES }
    validates :target_type, presence: true, inclusion: { in: TARGET_TYPES }
    validates :start_time, presence: true
    validates :value, numericality: { greater_than: 0 }, if: -> { requires_value? }

    serialize :config, coder: JSON

    scope :active, -> { where("start_time <= ? AND (end_time IS NULL OR end_time >= ?)", Time.current, Time.current) }

    def active?
      start_time <= Time.current && (end_time.nil? || end_time >= Time.current)
    end

    def applies_to?(item)
      return false unless active?

      case target_type
      when "Item"
        item.id == target_id
      when "Category"
        # Compare against normalized association name if present, else legacy string
        category_name = item.respond_to?(:category) && item.category.respond_to?(:name) ? item.category.name : item.category
        category_name == target_id_value
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
  end
end
