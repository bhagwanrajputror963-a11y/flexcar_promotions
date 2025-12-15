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
  end
end
