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

  describe 'polymorphic target association' do
    let(:item) { create(:item, name: 'Laptop', price: 1000, category: 'electronics') }
    let!(:category) { FlexcarPromotions::Category.find_by(name: 'electronics') || FlexcarPromotions::Category.create!(name: 'electronics') }

    context 'when using target= with an Item' do
      it 'sets target_type to "Item"' do
        promotion = described_class.new(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          target: item,
          start_time: Time.current
        )

        expect(promotion.target_type).to eq('Item')
      end

      it 'sets target_id to the item id' do
        promotion = described_class.new(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          target: item,
          start_time: Time.current
        )

        expect(promotion.target_id).to eq(item.id)
      end

      it 'can be saved and retrieved' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          target: item,
          start_time: Time.current
        )

        expect(promotion.reload.target_type).to eq('Item')
        expect(promotion.target_id).to eq(item.id)
      end

      it 'target getter returns the correct item' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          target: item,
          start_time: Time.current
        )

        expect(promotion.target).to eq(item)
        expect(promotion.target.name).to eq('Laptop')
      end

      it 'applies_to? works correctly with target: syntax' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          target: item,
          start_time: Time.current
        )

        expect(promotion.applies_to?(item)).to be true

        other_item = create(:item, name: 'Mouse')
        expect(promotion.applies_to?(other_item)).to be false
      end
    end

    context 'when using target= with a Category' do
      it 'sets target_type to "Category"' do
        promotion = described_class.new(
          name: 'Test Promo',
          promotion_type: 'percentage_discount',
          value: 15,
          target: category,
          start_time: Time.current
        )

        expect(promotion.target_type).to eq('Category')
      end

      it 'sets target_id to the category id' do
        promotion = described_class.new(
          name: 'Test Promo',
          promotion_type: 'percentage_discount',
          value: 15,
          target: category,
          start_time: Time.current
        )

        expect(promotion.target_id).to eq(category.id)
      end

      it 'can be saved and retrieved' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'percentage_discount',
          value: 15,
          target: category,
          start_time: Time.current
        )

        expect(promotion.reload.target_type).to eq('Category')
        expect(promotion.target_id).to eq(category.id)
      end

      it 'target getter returns the correct category' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'percentage_discount',
          value: 15,
          target: category,
          start_time: Time.current
        )

        expect(promotion.target).to eq(category)
        expect(promotion.target.name).to eq('electronics')
      end

      it 'applies_to? works correctly with category target' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'percentage_discount',
          value: 15,
          target: category,
          start_time: Time.current
        )

        item_in_category = create(:item, category: 'electronics')
        expect(promotion.applies_to?(item_in_category)).to be true

        item_in_other_category = create(:item, category: 'clothing')
        expect(promotion.applies_to?(item_in_other_category)).to be false
      end
    end

    context 'when setting target to nil' do
      it 'clears both target_type and target_id' do
        promotion = described_class.new(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          target: item,
          start_time: Time.current
        )

        promotion.target = nil

        expect(promotion.target_type).to be_nil
        expect(promotion.target_id).to be_nil
      end
    end

    context 'backward compatibility with old syntax' do
      it 'old target_type and target_id syntax still works' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          target_type: 'Item',
          target_id: item.id,
          start_time: Time.current
        )

        expect(promotion.target_type).to eq('Item')
        expect(promotion.target_id).to eq(item.id)
        expect(promotion.applies_to?(item)).to be true
      end

      it 'old category syntax with config still works' do
        promotion = described_class.create!(
          name: 'Test Promo',
          promotion_type: 'percentage_discount',
          value: 15,
          target_type: 'Category',
          start_time: Time.current,
          config: { 'category' => 'electronics' }
        )

        item_in_category = create(:item, category: 'electronics')
        expect(promotion.applies_to?(item_in_category)).to be true
      end
    end

    context 'normalizes target_type from full class name' do
      it 'converts FlexcarPromotions::Item to Item' do
        promotion = described_class.new(
          name: 'Test Promo',
          promotion_type: 'flat_discount',
          value: 20,
          start_time: Time.current
        )

        # Simulate what Rails polymorphic association would do
        promotion.target_type = 'FlexcarPromotions::Item'
        promotion.target_id = item.id
        promotion.valid?

        expect(promotion.target_type).to eq('Item')
      end

      it 'converts FlexcarPromotions::Category to Category' do
        promotion = described_class.new(
          name: 'Test Promo',
          promotion_type: 'percentage_discount',
          value: 15,
          start_time: Time.current
        )

        promotion.target_type = 'FlexcarPromotions::Category'
        promotion.target_id = category.id
        promotion.valid?

        expect(promotion.target_type).to eq('Category')
      end
    end
  end
end
