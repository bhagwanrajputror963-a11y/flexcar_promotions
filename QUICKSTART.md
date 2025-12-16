# Quick Start Guide

## Installation & Setup (2 minutes)

```bash
cd flexcar_promotions
bundle install
bin/rails db:migrate
```

## Run Tests (30 seconds)

```bash
bundle exec rspec
```

**Expected Output**: 47 examples, 0 failures

## Run Demo (10 seconds)

```bash
bundle exec rails runner demo.rb
```

**Demo showcases**:
- Creating items (quantity and weight-based)
- Creating 4 types of promotions
- Adding items to cart
- Calculating best prices automatically
- Showing itemized pricing with discounts

## Quick Usage Example

### Ruby Console

```bash
bin/rails console
```

```ruby
# Create items
laptop = FlexcarPromotions::Item.create!(
  name: 'Laptop', price: 1000, sale_unit: 'quantity', category: 'electronics'
)

# Create promotion
FlexcarPromotions::Promotion.create!(
  name: '10% off',
  promotion_type: 'percentage_discount',
  value: 10,
  target_type: 'Item',
  target_id: laptop.id,
  start_time: Time.current
)

# Create cart and add item
cart = FlexcarPromotions::Cart.create!
cart.add_item(laptop, quantity: 1)

# Get pricing with promotion
pricing = cart.calculate_total
# => { subtotal: 1000.00, total_discount: 100.00, total: 900.00, items: [...] }
```

## Project Structure

```
flexcar_promotions/
├── app/
│   ├── models/              # Item, Cart, CartItem, Promotion
│   └── services/            # PricingService & Promotion Calculators
├── spec/                    # 47 comprehensive specs
├── db/migrate/              # 4 migrations
├── demo.rb                  # Working demo script
├── README.md                # Full documentation
├── INTEGRATION.md           # Integration guide
└── SUBMISSION.md            # Assignment summary
```

## Key Files to Review

1. **app/models/flexcar_promotions/cart.rb** - Cart with add/remove/calculate
2. **app/services/flexcar_promotions/pricing_service.rb** - Main pricing logic
3. **app/services/flexcar_promotions/promotions/** - Promotion calculators
4. **spec/** - Comprehensive test suite
5. **demo.rb** - Working example with output

## What This Engine Provides

✅ Complete inventory management (items, categories, brands)
✅ 4 promotion types (flat, percentage, buy-x-get-y, weight threshold)
✅ Smart cart with automatic best-price calculation
✅ Time-based promotions (start/end dates)
✅ Category-level promotions
✅ Comprehensive test coverage
✅ Production-ready code quality
✅ Clean architecture with service objects

## Next Steps

- Read **README.md** for detailed usage
- Check **INTEGRATION.md** for Rails app integration
- Review **SUBMISSION.md** for design decisions
- Explore the test suite in **spec/**

## Questions?

Contact: Bhagwan Singh (bhagwanrajputror963@gmail.com)
