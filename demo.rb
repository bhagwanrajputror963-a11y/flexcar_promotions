# frozen_string_literal: true

# Demo script showcasing the Flexcar Promotions Engine
# Run with: bundle exec rails runner demo.rb

puts "\n" + "=" * 80
puts "FLEXCAR PROMOTIONS ENGINE - DEMO"
puts "=" * 80 + "\n\n"

# Clear existing data
puts "Clearing existing data..."
FlexcarPromotions::CartItem.destroy_all
FlexcarPromotions::Cart.destroy_all
FlexcarPromotions::Promotion.destroy_all
FlexcarPromotions::Item.destroy_all

# Create brands and categories (normalized)
puts "\n📦 Creating brands and categories..."
puts "-" * 80

apple     = FlexcarPromotions::Brand.find_or_create_by!(name: 'Apple')
logitech  = FlexcarPromotions::Brand.find_or_create_by!(name: 'Logitech')
corsair   = FlexcarPromotions::Brand.find_or_create_by!(name: 'Corsair')
starbucks = FlexcarPromotions::Brand.find_or_create_by!(name: 'Starbucks')

electronics = FlexcarPromotions::Category.find_or_create_by!(name: 'electronics')
accessories = FlexcarPromotions::Category.find_or_create_by!(name: 'accessories')
food        = FlexcarPromotions::Category.find_or_create_by!(name: 'food')

puts "✓ Brands: #{[ apple.name, logitech.name, corsair.name, starbucks.name ].join(', ')}"
puts "✓ Categories: #{[ electronics.name, accessories.name, food.name ].join(', ')}"

# Create items linked to normalized records (keep legacy strings too)
puts "\n📦 Creating items..."
puts "-" * 80

laptop = FlexcarPromotions::Item.create!(
  name: 'MacBook Pro',
  price: 2000.00,
  sale_unit: 'quantity',
  category: 'electronics',
  brand: 'Apple',
  brand_id: apple.id,
  category_id: electronics.id
)
puts "✓ Created: #{laptop.name} - $#{laptop.price} (#{laptop.category}/#{laptop.category&.name})"

mouse = FlexcarPromotions::Item.create!(
  name: 'Wireless Mouse',
  price: 50.00,
  sale_unit: 'quantity',
  category: 'accessories',
  brand: 'Logitech',
  brand_id: logitech.id,
  category_id: accessories.id
)
puts "✓ Created: #{mouse.name} - $#{mouse.price} (#{mouse.category}/#{mouse.category&.name})"

keyboard = FlexcarPromotions::Item.create!(
  name: 'Mechanical Keyboard',
  price: 150.00,
  sale_unit: 'quantity',
  category: 'accessories',
  brand: 'Corsair',
  brand_id: corsair.id,
  category_id: accessories.id
)
puts "✓ Created: #{keyboard.name} - $#{keyboard.price} (#{keyboard.category}/#{keyboard.category&.name})"

coffee = FlexcarPromotions::Item.create!(
  name: 'Premium Coffee Beans',
  price: 0.05, # per gram
  sale_unit: 'weight',
  category: 'food',
  brand: 'Starbucks',
  brand_id: starbucks.id,
  category_id: food.id
)
puts "✓ Created: #{coffee.name} - $#{coffee.price}/gram (#{coffee.category}/#{coffee.category&.name})"

# Create promotions
puts "\n🎁 Creating promotions..."
puts "-" * 80

promo1 = FlexcarPromotions::Promotion.create!(
  name: '$200 off MacBook Pro',
  promotion_type: 'flat_discount',
  value: 200.00,
  target_type: 'Item',
  target_id: laptop.id,
  start_time: 1.day.ago,
  end_time: 1.week.from_now
)
puts "✓ Created: #{promo1.name} (#{promo1.promotion_type})"

promo2 = FlexcarPromotions::Promotion.create!(
  name: '20% off Accessories',
  promotion_type: 'percentage_discount',
  value: 20,
  target_type: 'Category',
  start_time: 1.day.ago,
  config: { 'category' => 'accessories' }
)
puts "✓ Created: #{promo2.name} (#{promo2.promotion_type})"

promo3 = FlexcarPromotions::Promotion.create!(
  name: 'Buy 2 Keyboards Get 1 50% Off',
  promotion_type: 'buy_x_get_y',
  target_type: 'Item',
  target_id: keyboard.id,
  start_time: 1.day.ago,
  config: {
    'buy_quantity' => 2,
    'get_quantity' => 1,
    'discount_percent' => 50
  }
)
puts "✓ Created: #{promo3.name} (#{promo3.promotion_type})"

promo4 = FlexcarPromotions::Promotion.create!(
  name: '50% off Coffee 200g+',
  promotion_type: 'weight_threshold',
  value: 50,
  target_type: 'Item',
  target_id: coffee.id,
  start_time: 1.day.ago,
  config: { 'threshold_weight' => 200 }
)
puts "✓ Created: #{promo4.name} (#{promo4.promotion_type})"

# Additional overlapping promotions to demonstrate rules
promo5 = FlexcarPromotions::Promotion.create!(
  name: '15% off Accessories (overlap)',
  promotion_type: 'percentage_discount',
  value: 15,
  target_type: 'Category',
  start_time: 1.day.ago,
  config: { 'category' => 'accessories' }
)
puts "✓ Created: #{promo5.name} (#{promo5.promotion_type})"

promo6 = FlexcarPromotions::Promotion.create!(
  name: '$30 off Mouse (overlap)',
  promotion_type: 'flat_discount',
  value: 30.00,
  target_type: 'Item',
  target_id: mouse.id,
  start_time: 1.day.ago,
  end_time: 3.days.from_now
)
puts "✓ Created: #{promo6.name} (#{promo6.promotion_type})"

# Inactive promotions to demonstrate non-application
expired_promo = FlexcarPromotions::Promotion.create!(
  name: 'Expired: 50% off Keyboard',
  promotion_type: 'percentage_discount',
  value: 50,
  target_type: 'Item',
  target_id: keyboard.id,
  start_time: 5.days.ago,
  end_time: 2.days.ago
)
puts "✓ Created: #{expired_promo.name} (expired)"

future_promo = FlexcarPromotions::Promotion.create!(
  name: 'Future: 25% off Laptop',
  promotion_type: 'percentage_discount',
  value: 25,
  target_type: 'Item',
  target_id: laptop.id,
  start_time: 2.days.from_now,
  end_time: 10.days.from_now
)
puts "✓ Created: #{future_promo.name} (starts later)"

# Create cart and add items
puts "\n🛒 Creating shopping cart..."
puts "-" * 80

cart = FlexcarPromotions::Cart.create!
puts "✓ Cart created with ID: #{cart.id}"

puts "\n📝 Adding items to cart..."
cart.add_item(laptop, quantity: 1)
puts "  + 1x #{laptop.name}"

cart.add_item(mouse, quantity: 2)
puts "  + 2x #{mouse.name}"

cart.add_item(keyboard, quantity: 3)
puts "  + 3x #{keyboard.name}"

cart.add_item(coffee, weight: 250)
puts "  + 250g #{coffee.name}"

# Calculate pricing
puts "\n💰 Calculating final price with promotions..."
puts "=" * 80

result = cart.calculate_total

puts "\nITEM BREAKDOWN:"
puts "-" * 80
result[:items].each do |item_result|
  item_name = item_result[:item_name]
  amount = item_result[:quantity] || "#{item_result[:weight]}g"
  base_price = sprintf("$%.2f", item_result[:base_price])
  discount = sprintf("$%.2f", item_result[:discount])
  final_price = sprintf("$%.2f", item_result[:final_price])
  promotion = item_result[:promotion] || "No promotion"

  puts "\n#{item_name} (#{amount})"
  puts "  Base Price:    #{base_price}"
  puts "  Discount:      -#{discount}"
  puts "  Final Price:   #{final_price}"
  puts "  Promotion:     #{promotion}"
end

puts "\n" + "=" * 80
puts "CART TOTALS:"
puts "-" * 80
puts "Subtotal:        $#{sprintf('%.2f', result[:subtotal])}"
puts "Total Discount:  -$#{sprintf('%.2f', result[:total_discount])}"
puts "FINAL TOTAL:     $#{sprintf('%.2f', result[:total])}"
puts "=" * 80

# Calculate savings
savings_percent = (result[:total_discount] / result[:subtotal] * 100).round(1)
puts "\n🎉 You saved $#{sprintf('%.2f', result[:total_discount])} (#{savings_percent}%)!"

puts "\n" + "=" * 80
puts "DEMO COMPLETED SUCCESSFULLY!"
puts "=" * 80 + "\n\n"

# Rules summary and verification
puts "\nRULES VERIFICATION:"
puts "-" * 80

applied_promotions = result[:items].map { |i| i[:promotion] }.compact
accessories_20_count = result[:items].count { |i| i[:promotion] == '20% off Accessories' }
mouse_promo = result[:items].find { |i| i[:item_name] == 'Wireless Mouse' }&.dig(:promotion)
keyboard_promo = result[:items].find { |i| i[:item_name] == 'Mechanical Keyboard' }&.dig(:promotion)

puts "- Multiple promotions in cart: #{applied_promotions.uniq.size} (across different items)"
puts "- Each item uses at most one promotion:"
puts "  Mouse -> #{mouse_promo || 'None'}"
puts "  Keyboard -> #{keyboard_promo || 'None'}"
puts "- Single-use category promo applied once: '20% off Accessories' used #{accessories_20_count} time(s)"
puts "- Start/end time honored: '$30 off Mouse' is active now (end in 3 days)"
puts "- Inactive promotions are ignored:"
keyboard_promo_name = result[:items].find { |i| i[:item_name] == 'Mechanical Keyboard' }&.dig(:promotion)
laptop_promo_name = result[:items].find { |i| i[:item_name] == 'MacBook Pro' }&.dig(:promotion)
puts "  Expired 50% keyboard promo → applied? #{keyboard_promo_name == 'Expired: 50% off Keyboard' ? 'Yes' : 'No'}"
puts "  Future 25% laptop promo → applied? #{laptop_promo_name == 'Future: 25% off Laptop' ? 'Yes' : 'No'}"
