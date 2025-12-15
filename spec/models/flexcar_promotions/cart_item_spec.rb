# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexcarPromotions::CartItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:cart) }
    it { is_expected.to belong_to(:item) }
  end

  describe 'validations' do
    let(:item_quantity) { create(:item, sale_unit: 'quantity') }
    let(:item_weight) { create(:item, :sold_by_weight) }
    let(:cart) { create(:cart) }

    context 'for quantity-based items' do
      it 'validates quantity is greater than 0' do
        cart_item = build(:cart_item, cart: cart, item: item_quantity, quantity: 0)
        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:quantity]).to be_present
      end

      it 'allows positive quantity' do
        cart_item = build(:cart_item, cart: cart, item: item_quantity, quantity: 5)
        expect(cart_item).to be_valid
      end
    end

    context 'for weight-based items' do
      it 'validates weight is greater than 0' do
        cart_item = build(:cart_item, :with_weight, cart: cart, item: item_weight, weight: 0)
        expect(cart_item).not_to be_valid
        expect(cart_item.errors[:weight]).to be_present
      end

      it 'allows positive weight' do
        cart_item = build(:cart_item, :with_weight, cart: cart, item: item_weight, weight: 100)
        expect(cart_item).to be_valid
      end
    end
  end

  describe '#base_price' do
    let(:cart) { create(:cart) }

    context 'for quantity-based items' do
      let(:item) { create(:item, price: 50.00, sale_unit: 'quantity') }
      let(:cart_item) { create(:cart_item, cart: cart, item: item, quantity: 3) }

      it 'calculates price as item price × quantity' do
        expect(cart_item.base_price).to eq(150.00)
      end
    end

    context 'for weight-based items' do
      let(:item) { create(:item, :sold_by_weight, price: 0.10) }
      let(:cart_item) { create(:cart_item, :with_weight, cart: cart, item: item, weight: 250) }

      it 'calculates price as item price × weight' do
        expect(cart_item.base_price).to eq(25.00)
      end
    end
  end

  describe '#amount' do
    let(:cart) { create(:cart) }

    it 'returns quantity for quantity-based items' do
      item = create(:item, sale_unit: 'quantity')
      cart_item = create(:cart_item, cart: cart, item: item, quantity: 5)
      expect(cart_item.amount).to eq(5)
    end

    it 'returns weight for weight-based items' do
      item = create(:item, :sold_by_weight)
      cart_item = create(:cart_item, :with_weight, cart: cart, item: item, weight: 300)
      expect(cart_item.amount).to eq(300)
    end
  end
end
