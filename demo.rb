# frozen_string_literal: true

# ============================================================
# FLEXCAR PROMOTIONS ENGINE – VERY CLEAR DEMO SCRIPT
# ============================================================
# PURPOSE:
# - Show EXACTLY which promotion applies to which item
# - Explain WHY that promotion was chosen
# - Prove inactive/overlapping promotions are ignored
#
# RUN:
#   bundle exec rails runner demo.rb
# ============================================================

puts "\n#{'=' * 90}"
puts "FLEXCAR PROMOTIONS ENGINE – EXPLAINED DEMO"
puts "#{'=' * 90}\n"

# ------------------------------------------------------------
# STEP 1: CLEAN DATABASE (KEEP DEMO REPEATABLE)
# ------------------------------------------------------------
puts "[STEP 1] Cleaning old data..."
FlexcarPromotions::CartItem.destroy_all
FlexcarPromotions::Cart.destroy_all
FlexcarPromotions::Promotion.destroy_all
FlexcarPromotions::Item.destroy_all
FlexcarPromotions::Brand.destroy_all
FlexcarPromotions::Category.destroy_all
puts "✔ Database cleaned\n"

# ------------------------------------------------------------
# STEP 2: CREATE BRANDS & CATEGORIES
# ------------------------------------------------------------
puts "[STEP 2] Creating brands and categories..."

apple     = FlexcarPromotions::Brand.create!(name: 'Apple')
logitech  = FlexcarPromotions::Brand.create!(name: 'Logitech')
corsair   = FlexcarPromotions::Brand.create!(name: 'Corsair')
starbucks = FlexcarPromotions::Brand.create!(name: 'Starbucks')

electronics = FlexcarPromotions::Category.create!(name: 'electronics')
accessories = FlexcarPromotions::Category.create!(name: 'accessories')
food        = FlexcarPromotions::Category.create!(name: 'food')

puts "✔ Brands: Apple, Logitech, Corsair, Starbucks"
puts "✔ Categories: electronics, accessories, food\n"

# ------------------------------------------------------------
# STEP 3: CREATE ITEMS
# ------------------------------------------------------------
puts "[STEP 3] Creating items..."

laptop = FlexcarPromotions::Item.create!(
  name: 'MacBook Pro',
  price: 2000,
  sale_unit: 'quantity',
  brand_id: apple.id,
  category_id: electronics.id
)

mouse = FlexcarPromotions::Item.create!(
  name: 'Wireless Mouse',
  price: 50,
  sale_unit: 'quantity',
  brand_id: logitech.id,
  category_id: accessories.id
)

keyboard = FlexcarPromotions::Item.create!(
  name: 'Mechanical Keyboard',
  price: 150,
  sale_unit: 'quantity',
  brand_id: corsair.id,
  category_id: accessories.id
)

coffee = FlexcarPromotions::Item.create!(
  name: 'Premium Coffee Beans',
  price: 0.05, # per gram
  sale_unit: 'weight',
  brand_id: starbucks.id,
  category_id: food.id
)

puts "✔ Items created: Laptop, Mouse, Keyboard, Coffee\n"

# ------------------------------------------------------------
# STEP 4: CREATE PROMOTIONS (WITH CLEAR INTENT)
# ------------------------------------------------------------
puts "[STEP 4] Creating promotions..."

# 1. ITEM LEVEL – FLAT DISCOUNT
FlexcarPromotions::Promotion.create!(
  name: '$200 OFF MACBOOK',
  promotion_type: 'flat_discount',
  value: 200,
  target: laptop,
  start_time: 1.day.ago,
  end_time: 1.week.from_now
)

# 2. CATEGORY LEVEL – PERCENTAGE DISCOUNT
FlexcarPromotions::Promotion.create!(
  name: '20% OFF ACCESSORIES',
  promotion_type: 'percentage_discount',
  value: 20,
  target: accessories,
  start_time: 1.day.ago
)

# 3. BUY X GET Y
FlexcarPromotions::Promotion.create!(
  name: 'BUY 2 KEYBOARDS GET 1 AT 50%',
  promotion_type: 'buy_x_get_y',
  target: keyboard,
  start_time: 1.day.ago,
  config: {
    'buy_quantity' => 2,
    'get_quantity' => 1,
    'discount_percent' => 50
  }
)

# 4. WEIGHT BASED PROMOTION
FlexcarPromotions::Promotion.create!(
  name: '50% OFF COFFEE ABOVE 200G',
  promotion_type: 'weight_threshold',
  value: 50,
  target: coffee,
  start_time: 1.day.ago,
  config: { 'threshold_weight' => 200 }
)

# 5. OVERLAPPING PROMOTION (SHOULD LOSE)
FlexcarPromotions::Promotion.create!(
  name: '15% OFF ACCESSORIES (LOW PRIORITY)',
  promotion_type: 'percentage_discount',
  value: 15,
  target: accessories,
  start_time: 1.day.ago
)

# 6. EXPIRED PROMOTION (SHOULD NOT APPLY)
FlexcarPromotions::Promotion.create!(
  name: 'EXPIRED 50% OFF KEYBOARD',
  promotion_type: 'percentage_discount',
  value: 50,
  target: keyboard,
  start_time: 10.days.ago,
  end_time: 5.days.ago
)

puts "✔ Promotions created (active, overlapping, expired)\n"

# ------------------------------------------------------------
# STEP 5: CREATE CART & ADD ITEMS
# ------------------------------------------------------------
puts "[STEP 5] Creating cart and adding items..."

cart = FlexcarPromotions::Cart.create!

cart.add_item(laptop, quantity: 1)    # Eligible for $200 off
cart.add_item(mouse, quantity: 2)     # Eligible for 20% category discount
cart.add_item(keyboard, quantity: 3)  # Eligible for BUY 2 GET 1
cart.add_item(coffee, weight: 250)    # Eligible for weight discount

puts "✔ Cart contains:"
puts "  - 1 x MacBook Pro"
puts "  - 2 x Mouse"
puts "  - 3 x Keyboard"
puts "  - 250g Coffee\n"

# ------------------------------------------------------------
# STEP 6: CALCULATE TOTALS & EXPLAIN PROMOTIONS
# ------------------------------------------------------------
puts "[STEP 6] Calculating totals and explaining promotions..."

result = cart.calculate_total

result[:items].each do |item|
  puts "\nITEM: #{item[:item_name]}"
  puts "  Quantity/Weight : #{item[:quantity] || item[:weight]}"
  puts "  Base Price      : $#{'%.2f' % item[:base_price]}"

  if item[:promotion]
    puts "  PROMOTION APPLIED: #{item[:promotion]}"
    puts "  Discount Given  : -$#{'%.2f' % item[:discount]}"
  else
    puts "  PROMOTION APPLIED: NONE"
  end

  puts "  Final Price     : $#{'%.2f' % item[:final_price]}"
end

# ------------------------------------------------------------
# STEP 7: FINAL CART SUMMARY
# ------------------------------------------------------------
puts "\n#{'-' * 90}"
puts "FINAL CART SUMMARY"
puts "#{'-' * 90}"
puts "Subtotal       : $#{'%.2f' % result[:subtotal]}"
puts "Total Discount : -$#{'%.2f' % result[:total_discount]}"
puts "FINAL TOTAL    : $#{'%.2f' % result[:total]}"

savings = (result[:total_discount] / result[:subtotal] * 100).round(2)
puts "YOU SAVED       : #{savings}%"

puts "\n✔ DEMO COMPLETED SUCCESSFULLY"
puts "#{'=' * 90}\n"
