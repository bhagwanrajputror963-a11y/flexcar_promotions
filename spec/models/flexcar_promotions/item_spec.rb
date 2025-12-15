# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexcarPromotions::Item, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:sale_unit) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than(0) }
    it { is_expected.to validate_inclusion_of(:sale_unit).in_array(%w[quantity weight]) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
  end

  describe '#sold_by_weight?' do
    it 'returns true when sale_unit is weight' do
      item = build(:item, :sold_by_weight)
      expect(item.sold_by_weight?).to be true
    end

    it 'returns false when sale_unit is quantity' do
      item = build(:item)
      expect(item.sold_by_weight?).to be false
    end
  end

  describe '#sold_by_quantity?' do
    it 'returns true when sale_unit is quantity' do
      item = build(:item)
      expect(item.sold_by_quantity?).to be true
    end

    it 'returns false when sale_unit is weight' do
      item = build(:item, :sold_by_weight)
      expect(item.sold_by_quantity?).to be false
    end
  end
end
