# frozen_string_literal: true

module FlexcarPromotions
  class Category < ApplicationRecord
    self.table_name = "flexcar_promotions_categories"

    has_many :items, class_name: "FlexcarPromotions::Item"

    validates :name, presence: true, uniqueness: true
  end
end
