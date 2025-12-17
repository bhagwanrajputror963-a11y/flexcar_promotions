# Flexcar Promotions Engine

A Rails engine for managing e-commerce inventory and promotional pricing. Designed as a modular, reusable component for B2B e-commerce platforms.

## Features

- **Flexible Item Management**: Items can be sold by quantity or weight, with category and brand support
- **Multiple Promotion Types**:
  - Flat discount (e.g., $20 off)
  - Percentage discount (e.g., 10% off)
  - Buy X Get Y (e.g., Buy 2 get 1 free, Buy 3 get 1 50% off)
  - Weight threshold (e.g., 50% off when buying 100+ grams)
- **Smart Pricing**: Automatically calculates the best price with available promotions
- **Time-based Promotions**: Promotions can have start and end times
- **Category-level Promotions**: Apply promotions to entire product categories
- **Best Price Guarantee**: Automatically selects the best available promotion for each item

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flexcar_promotions', path: 'path/to/flexcar_promotions'
```

Then execute:

```bash
$ bundle install
$ rails flexcar_promotions:install:migrations
$ rails db:migrate
```

## Usage

### Creating Brands and Categories

```ruby
# Create brands
tech_brand = FlexcarPromotions::Brand.create!(name: 'TechBrand')
coffee_co = FlexcarPromotions::Brand.create!(name: 'CoffeeCo')

# Create categories
electronics = FlexcarPromotions::Category.create!(name: 'Electronics')
food = FlexcarPromotions::Category.create!(name: 'Food')
```

### Creating Items

```ruby
# Item sold by quantity
laptop = FlexcarPromotions::Item.create!(
  name: 'Laptop',
  price: 1000.00,
  sale_unit: 'quantity',
  category: electronics,
  brand: tech_brand
)

# Item sold by weight
coffee = FlexcarPromotions::Item.create!(
  name: 'Coffee Beans',
  price: 0.05,  # price per gram
  sale_unit: 'weight',
  category: food,
  brand: coffee_co
)

# You can also use string values for convenience (auto-creates if needed)
laptop = FlexcarPromotions::Item.create!(
  name: 'Laptop',
  price: 1000.00,
  sale_unit: 'quantity',
  category: 'Electronics',  # finds or creates Category
  brand: 'TechBrand'        # finds or creates Brand
)
```

### Creating Promotions

```ruby
# Flat discount
FlexcarPromotions::Promotion.create!(
  name: '$20 off Laptop',
  promotion_type: 'flat_discount',
  value: 20.00,
  target: laptop,
  start_time: Time.current,
  end_time: 1.week.from_now
)

# Percentage discount on a category
FlexcarPromotions::Promotion.create!(
  name: '15% off Electronics',
  promotion_type: 'percentage_discount',
  value: 15,
  target: electronics,
  start_time: Time.current
)

# Buy X Get Y
FlexcarPromotions::Promotion.create!(
  name: 'Buy 2 Get 1 Free',
  promotion_type: 'buy_x_get_y',
  target: laptop,
  start_time: Time.current,
  config: {
    'buy_quantity' => 2,
    'get_quantity' => 1,
    'discount_percent' => 100  # 100% off = free
  }
)

# Weight threshold
FlexcarPromotions::Promotion.create!(
  name: '50% off 200g+ Coffee',
  promotion_type: 'weight_threshold',
  value: 50,
  target: coffee,
  start_time: Time.current,
  config: { 'threshold_weight' => 200 }
)

# Note: You can still use target_type and target_id if needed:
# target_type: 'Item', target_id: coffee.id
```

### Using the Cart

```ruby
# Create a cart
cart = FlexcarPromotions::Cart.create!

# Add items
cart.add_item(laptop, quantity: 1)
cart.add_item(coffee, weight: 250)

# Calculate total with promotions
pricing = cart.calculate_total

# Result structure:
{
  subtotal: 1012.50,
  total_discount: 6.25,
  total: 1006.25,
  items: [
    {
      item_id: 1,
      item_name: "Laptop",
      quantity: 1,
      weight: nil,
      base_price: 1000.00,
      discount: 0,
      final_price: 1000.00,
      promotion: nil
    },
    {
      item_id: 2,
      item_name: "Coffee Beans",
      quantity: nil,
      weight: 250,
      base_price: 12.50,
      discount: 6.25,
      final_price: 6.25,
      promotion: "50% off 200g+ Coffee"
    }
  ]
}

# Remove an item
cart.remove_item(laptop)

# Clear cart
cart.clear
```

## Architecture

### Models

- **Item**: Represents products in the catalog (belongs to Brand and Category)
- **Brand**: Product brands, has many Items
- **Category**: Product categories, has many Items
- **Cart**: Shopping cart that holds cart items
- **CartItem**: Join model between Cart and Item, stores quantity/weight
- **Promotion**: Defines promotional rules and discounts (can target Item, Brand, or Category)

### Services

- **PricingService**: Main service that calculates cart totals with promotions
- **Promotions::BaseCalculator**: Abstract base class for promotion calculators
- **Promotions::FlatDiscountCalculator**: Handles flat discount promotions
- **Promotions::PercentageDiscountCalculator**: Handles percentage discounts
- **Promotions::BuyXGetYCalculator**: Handles buy X get Y promotions
- **Promotions::WeightThresholdCalculator**: Handles weight-based promotions

### Design Decisions

1. **Service Object Pattern**: Promotion calculation logic is encapsulated in dedicated service classes, making it easy to add new promotion types

2. **Best Price Guarantee**: When multiple promotions apply to an item, the system automatically selects the one offering the highest discount

3. **Single Promotion per Item**: Each cart item can only use one promotion at a time, preventing complex stacking scenarios

4. **Single Use Promotions**: A promotion can only be applied once per cart, even if multiple items qualify

5. **Decimal Precision**: All prices use `decimal(10,2)` for accurate financial calculations

## Testing

The engine comes with comprehensive test coverage using RSpec:

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/flexcar_promotions/cart_spec.rb
```

Test coverage includes:
- Model validations and associations
- Cart operations (add, remove, clear)
- All promotion types
- Best price selection logic
- Category-based promotions
- Edge cases and error handling

## Code Quality

The codebase follows Ruby community best practices:

- **Ruby Style Guide**: Adheres to community conventions
- **RuboCop**: Configured for Rails and RSpec
- **Single Responsibility**: Each class has one clear purpose
- **DRY Principle**: No code duplication
- **Clear Naming**: Self-documenting code with meaningful variable names
- **Minimal Comments**: Code is readable without excessive comments

## Requirements

- Ruby >= 3.3.6
- Rails >= 8.1

## Development

```bash
# Install dependencies
bundle install

# Run migrations
bin/rails app:db:migrate RAILS_ENV=test

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

## Demo or testing

```bash
# Run
bundle exec rails runner demo.rb
```

## Improvements
1. Currency conversion using the money gem was not added since it was not part of the stated requirements.
2. Sidekiq or background jobs were not introduced because all logic can be handled synchronously in the main application.
3. Most critical test cases are covered, and additional tests can be added as requirements and edge cases evolve.
4. A demo.rb file was added to support manual testing and to clearly demonstrate the system behavior.
5. A service-oriented architecture was used to handle complex calculations while avoiding fat models and improving maintainability.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`bundle exec rspec`)
5. Commit your changes (`git commit -am 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Create a Pull Request

## License

This project is licensed under the MIT License - see the MIT-LICENSE file for details.

## Author

Bhagwan Singh

## Acknowledgments

Built as a take-home assignment for Flexcar, demonstrating clean architecture, test-driven development, and Rails best practices.
