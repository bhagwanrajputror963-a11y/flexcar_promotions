# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexcarPromotions::Promotion, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:promotion_type) }
    it { is_expected.to validate_presence_of(:target_type) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_inclusion_of(:promotion_type).in_array(%w[flat_discount percentage_discount buy_x_get_y weight_threshold]) }
    it { is_expected.to validate_inclusion_of(:target_type).in_array(%w[Item Category]) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_promotion) { create(:promotion, start_time: 1.day.ago, end_time: 1.day.from_now) }
      let!(:expired_promotion) { create(:promotion, :expired) }
      let!(:future_promotion) { create(:promotion, start_time: 1.day.from_now) }

      it 'returns only active promotions' do
        expect(described_class.active).to contain_exactly(active_promotion)
      end
    end
  end

  describe '#active?' do
    it 'returns true when within date range' do
      promotion = build(:promotion, start_time: 1.day.ago, end_time: 1.day.from_now)
      expect(promotion).to be_active
    end

    it 'returns true when end_time is nil' do
      promotion = build(:promotion, start_time: 1.day.ago, end_time: nil)
      expect(promotion).to be_active
    end

    it 'returns false when expired' do
      promotion = build(:promotion, :expired)
      expect(promotion).not_to be_active
    end

    it 'returns false when not yet started' do
      promotion = build(:promotion, start_time: 1.day.from_now)
      expect(promotion).not_to be_active
    end
  end

  describe '#applies_to?' do
    let(:item) { create(:item, category: 'electronics') }

    context 'when target is an item' do
      let(:promotion) { create(:promotion, target_type: 'Item', target_id: item.id) }

      it 'returns true for matching item' do
        expect(promotion.applies_to?(item)).to be true
      end

      it 'returns false for different item' do
        other_item = create(:item)
        expect(promotion.applies_to?(other_item)).to be false
      end
    end

    context 'when target is a category' do
      let(:promotion) { create(:promotion, :category_based) }

      it 'returns true for item in matching category' do
        expect(promotion.applies_to?(item)).to be true
      end

      it 'returns false for item in different category' do
        other_item = create(:item, category: 'clothing')
        expect(promotion.applies_to?(other_item)).to be false
      end
    end

    it 'returns false when promotion is not active' do
      promotion = create(:promotion, :expired, target_type: 'Item', target_id: item.id)
      expect(promotion.applies_to?(item)).to be false
    end
  end
end
