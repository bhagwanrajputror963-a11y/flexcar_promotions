# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: 'FlexcarPromotions::Item' do
    sequence(:name) { |n| "Item #{n}" }
    price { 10.00 }
    sale_unit { 'quantity' }
    category { FlexcarPromotions::Category.find_or_create_by(name: 'general') }
    brand { FlexcarPromotions::Brand.find_or_create_by(name: 'Generic Brand') }

    trait :sold_by_weight do
      sale_unit { 'weight' }
      price { 5.00 }
    end

    trait :electronics do
      category { FlexcarPromotions::Category.find_or_create_by(name: 'electronics') }
      brand { FlexcarPromotions::Brand.find_or_create_by(name: 'TechBrand') }
    end
  end

  factory :cart, class: 'FlexcarPromotions::Cart'

  factory :cart_item, class: 'FlexcarPromotions::CartItem' do
    cart
    item
    quantity { 1 }
    weight { nil }

    trait :with_weight do
      quantity { nil }
      weight { 100 }
    end
  end

  factory :promotion, class: 'FlexcarPromotions::Promotion' do
    sequence(:name) { |n| "Promotion #{n}" }
    promotion_type { 'percentage_discount' }
    value { 10 }
    target_type { 'Item' }
    start_time { 1.day.ago }
    end_time { 1.day.from_now }
    config { {} }

    trait :flat_discount do
      promotion_type { 'flat_discount' }
      value { 5.00 }
    end

    trait :percentage_discount do
      promotion_type { 'percentage_discount' }
      value { 20 }
    end

    trait :buy_x_get_y do
      promotion_type { 'buy_x_get_y' }
      value { nil }
      config { { 'buy_quantity' => 2, 'get_quantity' => 1, 'discount_percent' => 100 } }
    end

    trait :weight_threshold do
      promotion_type { 'weight_threshold' }
      value { 50 }
      config { { 'threshold_weight' => 100 } }
    end

    trait :category_based do
      target_type { 'Category' }
      target_id { nil }
      config { { 'category' => 'electronics' } }
    end

    trait :expired do
      start_time { 2.days.ago }
      end_time { 1.day.ago }
    end
  end
end
