# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edge Cases and Complex Scenarios', type: :model do
  let(:cart) { create(:cart) }

  describe 'empty cart' do
    it 'calculates total for empty cart' do
      result = cart.calculate_total

      expect(result[:subtotal]).to eq(0)
      expect(result[:total_discount]).to eq(0)
      expect(result[:total]).to eq(0)
      expect(result[:items]).to be_empty
    end
  end

  describe 'very large quantities' do
    it 'handles large quantities correctly' do
      item = create(:item, price: 1.99, sale_unit: 'quantity')
      cart.add_item(item, quantity: 10_000)

      result = cart.calculate_total
      expect(result[:subtotal]).to eq(19_900.00)
    end
  end

  describe 'very small prices' do
    it 'handles small fractional prices correctly' do
      item = create(:item, :sold_by_weight, price: 0.01)
      cart.add_item(item, weight: 100)

      result = cart.calculate_total
      expect(result[:subtotal]).to eq(1.00)
    end
  end

  describe 'decimal quantities' do
    it 'handles decimal quantities for quantity-based items' do
      item = create(:item, price: 10.00, sale_unit: 'quantity')
      cart.add_item(item, quantity: 2.5)

      result = cart.calculate_total
      expect(result[:subtotal]).to eq(25.00)
    end
  end

  describe 'promotion edge cases' do
    context 'when flat discount exceeds item price' do
      it 'caps discount at item price' do
        item = create(:item, price: 10.00, sale_unit: 'quantity')
        create(:promotion, :flat_discount, target_type: 'Item', target_id: item.id, value: 50.00)

        cart.add_item(item, quantity: 1)
        result = cart.calculate_total

        expect(result[:total_discount]).to eq(10.00)
        expect(result[:total]).to eq(0)
      end
    end

    context 'when percentage is 100%' do
      it 'makes item free' do
        item = create(:item, price: 100.00, sale_unit: 'quantity')
        create(:promotion, :percentage_discount, target_type: 'Item', target_id: item.id, value: 100)

        cart.add_item(item, quantity: 1)
        result = cart.calculate_total

        expect(result[:total_discount]).to eq(100.00)
        expect(result[:total]).to eq(0)
      end
    end

    context 'with expired promotion' do
      it 'does not apply expired promotion' do
        item = create(:item, price: 100.00, sale_unit: 'quantity')
        create(:promotion, :expired, target_type: 'Item', target_id: item.id, value: 50)

        cart.add_item(item, quantity: 1)
        result = cart.calculate_total

        expect(result[:total_discount]).to eq(0)
        expect(result[:total]).to eq(100.00)
      end
    end

    context 'with future promotion' do
      it 'does not apply future promotion' do
        item = create(:item, price: 100.00, sale_unit: 'quantity')
        create(:promotion,
               :percentage_discount,
               target_type: 'Item',
               target_id: item.id,
               value: 50,
               start_time: 1.day.from_now)

        cart.add_item(item, quantity: 1)
        result = cart.calculate_total

        expect(result[:total_discount]).to eq(0)
        expect(result[:total]).to eq(100.00)
      end
    end

    context 'buy X get Y with insufficient quantity' do
      it 'does not apply discount' do
        item = create(:item, price: 10.00, sale_unit: 'quantity')
        create(:promotion, :buy_x_get_y, target_type: 'Item', target_id: item.id)

        cart.add_item(item, quantity: 1)
        result = cart.calculate_total

        expect(result[:total_discount]).to eq(0)
      end
    end

    context 'weight threshold not met' do
      it 'does not apply discount' do
        item = create(:item, :sold_by_weight, price: 0.10)
        create(:promotion, :weight_threshold, target_type: 'Item', target_id: item.id)

        cart.add_item(item, weight: 50)
        result = cart.calculate_total

        expect(result[:total_discount]).to eq(0)
      end
    end
  end

  describe 'concurrent same items' do
    it 'prevents duplicate cart items' do
      item = create(:item, price: 10.00, sale_unit: 'quantity')

      cart.add_item(item, quantity: 1)
      cart.add_item(item, quantity: 2)

      expect(cart.cart_items.count).to eq(1)
      expect(cart.cart_items.first.quantity).to eq(3)
    end
  end

  describe 'removing non-existent item' do
    it 'handles gracefully' do
      item = create(:item, price: 10.00, sale_unit: 'quantity')

      expect { cart.remove_item(item) }.not_to raise_error
      expect(cart.cart_items.count).to eq(0)
    end
  end

  describe 'mixed quantity and weight items in same cart' do
    it 'calculates correctly' do
      item_quantity = create(:item, name: 'Widget', price: 50.00, sale_unit: 'quantity')
      item_weight = create(:item, :sold_by_weight, name: 'Bulk Item', price: 0.05)

      cart.add_item(item_quantity, quantity: 2)
      cart.add_item(item_weight, weight: 100)

      result = cart.calculate_total
      expect(result[:subtotal]).to eq(105.00)
    end
  end

  describe 'rounding precision' do
    it 'maintains correct decimal precision' do
      item = create(:item, price: 33.33, sale_unit: 'quantity')
      create(:promotion, :percentage_discount, target_type: 'Item', target_id: item.id, value: 33)

      cart.add_item(item, quantity: 1)
      result = cart.calculate_total

      discount = 10.99
      expect(result[:total_discount]).to be_within(0.01).of(discount)
      expect(result[:total]).to be_within(0.01).of(22.34)
    end
  end

  describe 'negative quantity validation' do
    it 'prevents negative quantities' do
      item = create(:item, price: 10.00, sale_unit: 'quantity')
      cart_item = build(:cart_item, cart: cart, item: item, quantity: -1)

      expect(cart_item).not_to be_valid
    end
  end

  describe 'negative weight validation' do
    it 'prevents negative weights' do
      item = create(:item, :sold_by_weight, price: 0.10)
      cart_item = build(:cart_item, :with_weight, cart: cart, item: item, weight: -10)

      expect(cart_item).not_to be_valid
    end
  end
end
