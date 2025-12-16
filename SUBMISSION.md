# Flexcar Take-Home Assignment - Submission Summary

## 📦 Deliverable

**Flexcar Promotions Engine** - A production-ready Rails Engine for e-commerce inventory and promotional pricing.

## ✅ Requirements Fulfilled

### Item Management
- ✅ Items can be sold by weight or quantity
- ✅ Items can be grouped into categories
- ✅ Items can have a brand
- ✅ Multiple items of each type can be added to cart
- ✅ No tax calculations (as specified)

### Promotion Types
- ✅ Flat fee discount (e.g., $20 off)
- ✅ Percentage discount (e.g., 10% off)
- ✅ Buy X Get Y discount (e.g., Buy 2 get 1 free, Buy 3 get 1 50% off)
- ✅ Weight threshold discounts (e.g., buy more than 100g and get 50% off)

### Promotion Rules
- ✅ Promotions valid for individual items or categories
- ✅ Promotions have start time (required)
- ✅ Promotions may have end time (optional)
- ✅ Multiple promotions can apply to cart if valid
- ✅ Each item only valid for one promotion (best discount wins)
- ✅ Only one instance of promotion applied at a time

### Cart Functionality
- ✅ Add items to cart
- ✅ Remove items from cart
- ✅ View items in cart
- ✅ Best possible price shown when items added
- ✅ Automatic promotion calculation

## 🏗️ Architecture Decisions

### Why Rails Engine?

I chose to implement this as a **Rails Engine** for several strategic reasons:

1. **B2B SaaS Platform**: The requirements explicitly state this is for a "business-to-business software platform." A Rails Engine is perfect for this use case as it:
   - Can be packaged as a gem and distributed to multiple client applications
   - Provides complete isolation and encapsulation
   - Allows customers to integrate the promotions system into their existing Rails apps

2. **Modularity & Reusability**:
   - The engine is self-contained with its own models, migrations, and services
   - Can be versioned and maintained independently
   - Easy to test in isolation

3. **Clean Architecture**:
   - Follows Single Responsibility Principle
   - Service Object Pattern for promotion calculations
   - Strategy Pattern for different promotion types
   - Minimal dependencies

4. **Production Ready**:
   - Comprehensive test coverage (47 passing specs)
   - Proper database indexes for performance
   - Decimal precision for financial calculations
   - Error handling and validations

## 📊 Code Quality Metrics

- **Test Coverage**: 73 specs, 0 failures
- **Code Organization**:
  - 6 Models (Item, Brand, Category, Cart, CartItem, Promotion) with validations and associations
  - 5 Service objects following Strategy pattern
  - 1 Main pricing service coordinating calculations
- **Documentation**:
  - Comprehensive README with usage examples
  - Integration guide for host applications
  - Demo script showcasing all features
- **Style**: Follows Ruby Style Guide and Rails conventions

## 🚀 How to Run

### Setup
```bash
cd flexcar_promotions
bundle install
bin/rails db:migrate
```

### Run Tests
```bash
bundle exec rspec --format documentation
```

### Run Demo
```bash
bundle exec rails runner demo.rb
```

## 📁 Project Structure

```
flexcar_promotions/
├── app/
│   ├── models/flexcar_promotions/
│   │   ├── item.rb
│   │   ├── brand.rb
│   │   ├── category.rb
│   │   ├── cart.rb
│   │   ├── cart_item.rb
│   │   └── promotion.rb
│   └── services/flexcar_promotions/
│       ├── pricing_service.rb
│       └── promotions/
│           ├── base_calculator.rb
│           ├── flat_discount_calculator.rb
│           ├── percentage_discount_calculator.rb
│           ├── buy_x_get_y_calculator.rb
│           └── weight_threshold_calculator.rb
├── spec/
│   ├── models/
│   ├── services/
│   └── factories/
├── db/migrate/
├── README.md
├── INTEGRATION.md
└── demo.rb
```

## 💡 Key Features

### 1. Smart Promotion Selection
The engine automatically selects the best promotion when multiple apply:
```ruby
cart.calculate_total
# Returns the pricing with best discounts applied
```

### 2. Flexible Promotion Configuration
Promotions use a JSON `config` field for type-specific settings:
```ruby
# Buy X Get Y
config: { 'buy_quantity' => 2, 'get_quantity' => 1, 'discount_percent' => 100 }

# Weight Threshold
config: { 'threshold_weight' => 200 }

# Category-based
config: { 'category' => 'electronics' }
```

### 3. Real-time Price Calculation
Every time an item is added, the best price is calculated immediately.

### 4. Extensible Design
New promotion types can be added by:
1. Creating a new calculator class
2. Adding the type to `Promotion::PROMOTION_TYPES`
3. Updating the calculator class mapping

## 🧪 Test Coverage

```
FlexcarPromotions::Brand
  ✓ Validations
  ✓ Associations with Items

FlexcarPromotions::Category
  ✓ Validations
  ✓ Associations with Items

FlexcarPromotions::Cart
  ✓ Associations
  ✓ Add/Remove items
  ✓ Validation for quantity vs weight
  ✓ Pricing delegation

FlexcarPromotions::Item
  ✓ All validations
  ✓ Sale unit helpers
  ✓ Associations

FlexcarPromotions::Promotion
  ✓ All validations
  ✓ Active scope
  ✓ Applicability logic
  ✓ Time-based activation

FlexcarPromotions::PricingService
  ✓ Without promotions
  ✓ Flat discount
  ✓ Percentage discount
  ✓ Buy X Get Y
  ✓ Weight threshold
  ✓ Category-based promotions
  ✓ Best discount selection
  ✓ Single-use promotions

73 examples, 0 failures
```

## 🎯 Design Patterns Used

1. **Service Object Pattern**: Encapsulates business logic for pricing calculations
2. **Strategy Pattern**: Different calculator classes for each promotion type
3. **Factory Pattern**: FactoryBot for test data creation
4. **Repository Pattern**: ActiveRecord models act as repositories

## 📝 Code Principles Followed

- **DRY**: No code duplication
- **SOLID**:
  - Single Responsibility: Each class has one purpose
  - Open/Closed: Easy to extend with new promotion types
  - Liskov Substitution: All calculators inherit from base
  - Interface Segregation: Minimal interfaces
  - Dependency Inversion: Depends on abstractions
- **YAGNI**: Only implemented what was required
- **KISS**: Simple, readable code without over-engineering

## 🔒 Production Considerations

1. **Database Indexes**: Proper indexes on foreign keys and query columns
2. **Decimal Precision**: `decimal(10,2)` for accurate money calculations
3. **Validations**: Comprehensive validations on all models
4. **Error Handling**: Proper error messages for invalid operations
5. **Thread Safety**: Service objects are stateless and thread-safe

## 📚 Documentation

- **README.md**: Complete usage guide with examples
- **INTEGRATION.md**: How to integrate into existing Rails apps
- **demo.rb**: Working demo script
- **Code Comments**: Minimal but meaningful comments
- **Self-documenting**: Clear naming conventions

## 🎉 Demo Output

The demo script creates a realistic shopping scenario:
- MacBook Pro with $200 flat discount
- Wireless Mice with 20% category discount
- Mechanical Keyboards with Buy 2 Get 1 50% off
- Coffee with weight threshold discount

**Result**: Cart total of $2261.25 from $2562.50 (11.8% savings)

## 🤝 Submission Notes

This implementation prioritizes:
1. **Clean, readable code** over clever optimizations
2. **Comprehensive tests** over code coverage metrics
3. **Practical design** over theoretical perfection
4. **Real-world usability** over academic exercises

The Rails Engine approach demonstrates understanding of:
- Enterprise software architecture
- B2B SaaS platform design
- Modular, maintainable code organization
- Production-ready development practices

## 📧 Contact

**Bhagwan Singh**
Email: bhagwanrajputror963@gmail.com

---

Thank you for the opportunity to work on this assignment. I look forward to discussing the implementation!
