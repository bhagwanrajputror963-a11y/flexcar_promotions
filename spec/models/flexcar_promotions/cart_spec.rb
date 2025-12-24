# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexcarPromotions::Cart, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
    it { is_expected.to have_many(:items).through(:cart_items) }
  end

  describe '#add_item' do
    let(:cart) { create(:cart) }
    let(:item) { create(:item, price: 10.00) }

    context 'when item is sold by quantity' do
      it 'adds item with quantity to cart' do
        cart.add_item(item, quantity: 2)

        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.quantity).to eq(2)
      end

      it 'increments quantity if item already in cart' do
        cart.add_item(item, quantity: 2)
        cart.add_item(item, quantity: 3)

        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.quantity).to eq(5)
      end

      it 'raises error if quantity is not provided' do
        expect { cart.add_item(item) }.to raise_error(ArgumentError, /Quantity required/)
      end
    end

    context 'when item is sold by weight' do
      let(:item) { create(:item, :sold_by_weight, price: 5.00) }

      it 'adds item with weight to cart' do
        cart.add_item(item, weight: 150)

        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.weight).to eq(150)
      end

      it 'increments weight if item already in cart' do
        cart.add_item(item, weight: 100)
        cart.add_item(item, weight: 50)

        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.weight).to eq(150)
      end

      it 'raises error if weight is not provided' do
        expect { cart.add_item(item) }.to raise_error(ArgumentError, /Weight required/)
      end
    end
  end

  describe '#remove_item' do
    let(:cart) { create(:cart) }
    let(:item) { create(:item) }

    it 'removes item from cart' do
      cart.add_item(item, quantity: 2)
      cart.remove_item(item)

      expect(cart.cart_items.count).to eq(0)
    end

    it 'does nothing if item not in cart' do
      expect { cart.remove_item(item) }.not_to raise_error
    end
  end

  describe '#calculate_total' do
    let(:cart) { create(:cart) }

    it 'delegates to PricingService' do
      expect(FlexcarPromotions::PricingService).to receive(:new).with(cart).and_call_original
      cart.calculate_total
    end
  end

  describe '#clear' do
    let(:cart) { create(:cart) }
    let(:item) { create(:item) }

    it 'removes all items from cart' do
      cart.add_item(item, quantity: 2)
      cart.clear

      expect(cart.cart_items.count).to eq(0)
    end

    it 'clears applied promotion ids' do
      cart.add_item(item, quantity: 2)
      cart.applied_promotion_ids = [1, 2, 3]
      cart.save!
      cart.clear

      expect(cart.applied_promotion_ids).to eq([])
    end
  end

  describe '#apply_promo_code' do
    let(:cart) { create(:cart) }
    let(:item) { create(:item) }
    let(:promotion) { create(:promotion, :with_promo_code, target_type: 'Item', target_id: item.id) }

    before do
      cart.add_item(item, quantity: 1)
    end

    it 'applies valid promo code' do
      result = cart.apply_promo_code(promotion.promo_code)

      expect(result[:success]).to be true
      expect(cart.applied_promotion_ids).to include(promotion.id)
    end

    it 'returns error for invalid promo code' do
      result = cart.apply_promo_code('INVALID')

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Invalid promo code')
    end

    it 'returns error for expired promotion' do
      expired_promotion = create(:promotion, :expired, :with_promo_code, target_type: 'Item', target_id: item.id)
      result = cart.apply_promo_code(expired_promotion.promo_code)

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Promotion has expired')
    end

    it 'returns error when cart is empty' do
      empty_cart = create(:cart)
      result = empty_cart.apply_promo_code(promotion.promo_code)

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Cannot apply a promo code to an empty cart')
    end

    it 'returns error when no valid item in cart' do
      other_item = create(:item)
      other_cart = create(:cart)
      other_cart.add_item(other_item, quantity: 1)
      result = other_cart.apply_promo_code(promotion.promo_code)

      expect(result[:success]).to be false
      expect(result[:error]).to eq('No valid item in cart for this promo code')
    end

    it 'returns error when promo code already applied' do
      cart.apply_promo_code(promotion.promo_code)
      result = cart.apply_promo_code(promotion.promo_code)

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Promo code already applied')
    end
  end

  describe '#remove_promo_code' do
    let(:cart) { create(:cart) }
    let(:item) { create(:item) }
    let(:promotion) { create(:promotion, :with_promo_code, target_type: 'Item', target_id: item.id) }

    before do
      cart.add_item(item, quantity: 1)
      cart.apply_promo_code(promotion.promo_code)
    end

    it 'removes applied promo code' do
      result = cart.remove_promo_code(promotion.promo_code)

      expect(result[:success]).to be true
      expect(cart.applied_promotion_ids).not_to include(promotion.id)
    end

    it 'returns error for invalid promo code' do
      result = cart.remove_promo_code('INVALID')

      expect(result[:success]).to be false
      expect(result[:error]).to eq('Invalid promo code')
    end
  end
end
