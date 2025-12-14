# frozen_string_literal: true

require_relative "lib/flexcar_promotions/version"

Gem::Specification.new do |spec|
  spec.name        = "flexcar_promotions"
  spec.version     = FlexcarPromotions::VERSION
  spec.authors     = [ "Bhagwan Singh" ]
  spec.email       = [ "bhagwanrajputror963@gmail.com" ]
  spec.homepage    = "https://github.com/flexcar/flexcar_promotions"
  spec.summary     = "E-commerce inventory and promotions engine"
  spec.description = "A Rails engine for managing inventory items and promotional pricing in e-commerce platforms"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/flexcar/flexcar_promotions"
  spec.metadata["changelog_uri"] = "https://github.com/flexcar/flexcar_promotions/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.3.6"

  spec.add_dependency "rails", "~> 8.1"
  spec.add_dependency "pg", "~> 1.5"

  spec.add_development_dependency "factory_bot_rails", "~> 6.5"
  spec.add_development_dependency "rspec-rails", "~> 7.1"
  spec.add_development_dependency "rubocop", "~> 1.70"
  spec.add_development_dependency "rubocop-rails", "~> 2.27"
  spec.add_development_dependency "rubocop-rspec", "~> 3.3"
  spec.add_development_dependency "shoulda-matchers", "~> 6.4"
end
