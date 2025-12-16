# Flexcar Promotions Engine - Integration Guide

## Integrating into Your Rails Application

### Step 1: Add the Engine to Your Gemfile

```ruby
# In your Rails app's Gemfile
gem 'flexcar_promotions', path: '../flexcar_promotions'
# or from a git repository:
# gem 'flexcar_promotions', git: 'https://github.com/yourorg/flexcar_promotions'
```

### Step 2: Install Migrations

```bash
bundle install
rails flexcar_promotions:install:migrations
rails db:migrate
```

### Step 3: Use in Your Application

#### Example: E-commerce Controller

```ruby
class CheckoutController < ApplicationController
  def show
    @cart = current_cart
    @pricing = @cart.calculate_total
  end

  def add_to_cart
    item = FlexcarPromotions::Item.find(params[:item_id])

    if item.sold_by_quantity?
      current_cart.add_item(item, quantity: params[:quantity].to_i)
    else
      current_cart.add_item(item, weight: params[:weight].to_f)
    end

    redirect_to checkout_path, notice: "#{item.name} added to cart"
  end

  def remove_from_cart
    item = FlexcarPromotions::Item.find(params[:item_id])
    current_cart.remove_item(item)

    redirect_to checkout_path, notice: "#{item.name} removed from cart"
  end

  private

  def current_cart
    @current_cart ||= begin
      cart_id = session[:cart_id]
      cart = cart_id ? FlexcarPromotions::Cart.find_by(id: cart_id) : nil
      cart || create_cart
    end
  end

  def create_cart
    cart = FlexcarPromotions::Cart.create!
    session[:cart_id] = cart.id
    cart
  end
end
```

#### Example: Admin Promotions Controller

```ruby
class Admin::PromotionsController < AdminController
  def create
    @promotion = FlexcarPromotions::Promotion.new(promotion_params)

    if @promotion.save
      redirect_to admin_promotions_path, notice: 'Promotion created successfully'
    else
      render :new
    end
  end

  private

  def promotion_params
    params.require(:promotion).permit(
      :name, :promotion_type, :value, :target_type, :target_id,
      :start_time, :end_time, config: {}
    )
  end
end
```

#### Example: Cart View

```erb
<!-- app/views/checkout/show.html.erb -->
<h1>Shopping Cart</h1>

<table class="cart-items">
  <thead>
    <tr>
      <th>Item</th>
      <th>Quantity/Weight</th>
      <th>Price</th>
      <th>Discount</th>
      <th>Total</th>
      <th>Promotion</th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <% @pricing[:items].each do |item| %>
      <tr>
        <td><%= item[:item_name] %></td>
        <td><%= item[:quantity] || "#{item[:weight]}g" %></td>
        <td>$<%= sprintf('%.2f', item[:base_price]) %></td>
        <td class="discount">-$<%= sprintf('%.2f', item[:discount]) %></td>
        <td class="final-price">$<%= sprintf('%.2f', item[:final_price]) %></td>
        <td class="promotion"><%= item[:promotion] || '-' %></td>
        <td>
          <%= button_to 'Remove', remove_from_cart_path(item_id: item[:item_id]), method: :delete %>
        </td>
      </tr>
    <% end %>
  </tbody>
  <tfoot>
    <tr class="subtotal">
      <td colspan="4">Subtotal:</td>
      <td>$<%= sprintf('%.2f', @pricing[:subtotal]) %></td>
      <td></td>
    </tr>
    <tr class="discount-total">
      <td colspan="4">Total Savings:</td>
      <td class="discount">-$<%= sprintf('%.2f', @pricing[:total_discount]) %></td>
      <td></td>
    </tr>
    <tr class="total">
      <td colspan="4"><strong>Total:</strong></td>
      <td><strong>$<%= sprintf('%.2f', @pricing[:total]) %></strong></td>
      <td></td>
    </tr>
  </tfoot>
</table>

<%= link_to 'Continue Shopping', products_path, class: 'btn btn-secondary' %>
<%= link_to 'Checkout', checkout_confirm_path, class: 'btn btn-primary' %>
```

### Step 4: Customize (Optional)

You can extend the engine's models in your application:

```ruby
# app/models/flexcar_promotions/item.rb
module FlexcarPromotions
  class Item < ApplicationRecord
    # Add custom scopes or methods
    scope :featured, -> { where(featured: true) }

    def display_price
      "$#{sprintf('%.2f', price)}"
    end
  end
end
```

### Step 5: Background Jobs (Recommended)

For better performance with large carts, calculate pricing in the background:

```ruby
class CalculateCartPricingJob < ApplicationJob
  queue_as :default

  def perform(cart_id)
    cart = FlexcarPromotions::Cart.find(cart_id)
    pricing = cart.calculate_total

    # Cache the result
    Rails.cache.write("cart_pricing_#{cart_id}", pricing, expires_in: 5.minutes)
  end
end

# In your controller:
def show
  @cart = current_cart
  @pricing = Rails.cache.fetch("cart_pricing_#{@cart.id}", expires_in: 5.minutes) do
    @cart.calculate_total
  end
end
```

## API Usage

The engine can also be used as an API backend:

```ruby
class Api::V1::CartsController < Api::BaseController
  def show
    cart = FlexcarPromotions::Cart.find(params[:id])
    pricing = cart.calculate_total

    render json: {
      cart_id: cart.id,
      pricing: pricing
    }
  end

  def add_item
    cart = FlexcarPromotions::Cart.find(params[:id])
    item = FlexcarPromotions::Item.find(params[:item_id])

    if item.sold_by_quantity?
      cart.add_item(item, quantity: params[:quantity])
    else
      cart.add_item(item, weight: params[:weight])
    end

    render json: { success: true, cart: cart.calculate_total }
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```

## Testing Your Integration

```ruby
# spec/requests/checkout_spec.rb
require 'rails_helper'

RSpec.describe 'Checkout', type: :request do
  let(:item) { create(:item, price: 100.00) }
  let(:promotion) { create(:promotion, :percentage_discount, target_id: item.id, value: 10) }

  before { promotion }

  it 'applies promotions when calculating cart total' do
    post add_to_cart_path, params: { item_id: item.id, quantity: 1 }
    get checkout_path

    expect(response.body).to include('$90.00') # 10% off
  end
end
```

## Performance Considerations

1. **Cache promotion lookups**: Active promotions don't change frequently
2. **Index properly**: Ensure your database has appropriate indexes
3. **Eager load associations**: Use `includes` to avoid N+1 queries
4. **Background processing**: Calculate pricing asynchronously for large carts

## Security Considerations

1. **Validate input**: Always validate quantity/weight inputs
2. **Authorize actions**: Ensure users can only modify their own carts
3. **Rate limiting**: Prevent abuse of cart operations
4. **Audit trails**: Log promotion usage for fraud detection

## Support

For issues or questions, please open an issue on GitHub or contact the maintainer.
