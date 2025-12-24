# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexcarPromotions::PricingService do
  let(:cart) { create(:cart) }

  describe '#calculate' do
    context 'without promotions' do
      let!(:item1) { create(:item, name: 'Laptop', price: 1000.00, category: 'electronics') }
      let!(:item2) { create(:item, name: 'Mouse', price: 25.00, category: 'accessories') }

      before do
        cart.add_item(item1, quantity: 1)
        cart.add_item(item2, quantity: 2)
      end

      it 'calculates correct pricing without discounts' do
        result = described_class.new(cart).calculate

        expect(result[:subtotal]).to eq(1050.00)
        expect(result[:total_discount]).to eq(0)
        expect(result[:total]).to eq(1050.00)
        expect(result[:items].size).to eq(2)
      end
    end

    context 'with flat discount promotion' do
      let!(:item) { create(:item, name: 'Keyboard', price: 50.00) }
      let!(:promotion) { create(:promotion, :flat_discount, target_type: 'Item', target_id: item.id, value: 10.00) }

      before do
        cart.add_item(item, quantity: 1)
        cart.applied_promotion_ids = [promotion.id]
        cart.save!
      end

      it 'applies flat discount' do
        result = described_class.new(cart).calculate

        expect(result[:subtotal]).to eq(50.00)
        expect(result[:total_discount]).to eq(10.00)
        expect(result[:total]).to eq(40.00)
        expect(result[:items].first[:promotion]).to eq(promotion.name)
      end
    end

    context 'with percentage discount promotion' do
      let!(:item) { create(:item, name: 'Monitor', price: 300.00, category: 'electronics') }
      let!(:promotion) { create(:promotion, :percentage_discount, target_type: 'Item', target_id: item.id, value: 20) }

      before do
        cart.add_item(item, quantity: 1)
        cart.applied_promotion_ids = [promotion.id]
        cart.save!
      end

      it 'applies percentage discount' do
        result = described_class.new(cart).calculate

        expect(result[:subtotal]).to eq(300.00)
        expect(result[:total_discount]).to eq(60.00)
        expect(result[:total]).to eq(240.00)
      end
    end

    context 'with buy X get Y promotion' do
      let!(:item) { create(:item, name: 'Soda', price: 2.00) }
      let!(:promotion) do
        create(:promotion, :buy_x_get_y, target_type: 'Item', target_id: item.id,
               config: { 'buy_quantity' => 2, 'get_quantity' => 1, 'discount_percent' => 100 })
      end

      before do
        cart.add_item(item, quantity: 4)
        cart.applied_promotion_ids = [promotion.id]
        cart.save!
      end

      it 'applies buy 2 get 1 free discount' do
        result = described_class.new(cart).calculate

        expect(result[:subtotal]).to eq(8.00)
        expect(result[:total_discount]).to eq(2.00) # 1 free item (4 items = 1 complete set of 3)
        expect(result[:total]).to eq(6.00)
      end
    end

    context 'with weight threshold promotion' do
      let!(:item) { create(:item, :sold_by_weight, name: 'Coffee Beans', price: 0.05, category: 'food') }
      let!(:promotion) do
        create(:promotion, :weight_threshold, target_type: 'Item', target_id: item.id,
               value: 50, config: { 'threshold_weight' => 200 })
      end

      before do
        cart.add_item(item, weight: 250)
        cart.applied_promotion_ids = [promotion.id]
        cart.save!
      end

      it 'applies discount when weight threshold is met' do
        result = described_class.new(cart).calculate

        base_price = 0.05 * 250
        discount = base_price * 0.50

        expect(result[:subtotal]).to eq(base_price)
        expect(result[:total_discount]).to eq(discount)
        expect(result[:total]).to eq(base_price - discount)
      end
    end

    context 'with category-based promotion' do
      let!(:item1) { create(:item, :electronics, name: 'Tablet', price: 400.00) }
      let!(:item2) { create(:item, name: 'Book', price: 20.00, category: 'books') }
      let!(:promotion) do
        create(:promotion, :percentage_discount, :category_based,
               value: 15, config: { 'category' => 'electronics' })
      end

      before do
        cart.add_item(item1, quantity: 1)
        cart.add_item(item2, quantity: 1)
        cart.applied_promotion_ids = [promotion.id]
        cart.save!
      end

      it 'applies promotion only to items in specified category' do
        result = described_class.new(cart).calculate

        expect(result[:subtotal]).to eq(420.00)
        expect(result[:total_discount]).to eq(60.00) # 15% of 400
        expect(result[:total]).to eq(360.00)
      end
    end

    context 'with multiple applicable promotions (best discount wins)' do
      let!(:item) { create(:item, name: 'Headphones', price: 100.00) }
      let!(:flat_promotion) { create(:promotion, :flat_discount, target_type: 'Item', target_id: item.id, value: 15.00) }
      let!(:percentage_promotion) { create(:promotion, :percentage_discount, target_type: 'Item', target_id: item.id, value: 20) }

      before do
        cart.add_item(item, quantity: 1)
        cart.applied_promotion_ids = [flat_promotion.id, percentage_promotion.id]
        cart.save!
      end

      it 'applies the best discount' do
        result = described_class.new(cart).calculate

        expect(result[:total_discount]).to eq(20.00) # 20% is better than $15
        expect(result[:total]).to eq(80.00)
      end
    end

    context 'with multiple items and single-use promotions' do
      let!(:item1) { create(:item, name: 'Item 1', price: 50.00, category: 'test') }
      let!(:item2) { create(:item, name: 'Item 2', price: 50.00, category: 'test') }
      let!(:promotion) do
        create(:promotion, :percentage_discount, target_type: 'Item', target_id: item1.id,
               value: 50)
      end

      before do
        cart.add_item(item1, quantity: 1)
        cart.add_item(item2, quantity: 1)
        cart.applied_promotion_ids = [promotion.id]
        cart.save!
      end

      it 'applies promotion to first eligible item only' do
        result = described_class.new(cart).calculate

        items_with_promotion = result[:items].select { |i| i[:promotion].present? }
        expect(items_with_promotion.count).to eq(1)
        expect(result[:total_discount]).to eq(25.00)
      end
    end
  end
end
