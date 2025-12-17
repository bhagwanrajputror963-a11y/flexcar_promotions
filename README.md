# Flexcar Demo Project

This is a Rails 8 demonstration application showcasing the integration of the **Flexcar Promotions Engine** - a modular Rails engine for managing e-commerce inventory and promotional pricing.

## About This Project

This demo application integrates the `flexcar_promotions` engine to provide a complete example of:
- Item and inventory management
- Flexible promotional pricing (flat discounts, percentages, buy X get Y, weight-based)
- Shopping cart functionality with automatic best-price calculations
- Category and brand-based promotions

## Tech Stack

- **Ruby**: 3.3.6
- **Rails**: 8.1.1
- **Database**: PostgreSQL
- **Asset Pipeline**: Propshaft
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Background Jobs**: Solid Queue
- **Cache**: Solid Cache
- **WebSocket**: Solid Cable

## Prerequisites

- Ruby 3.3.6 or higher
- PostgreSQL 9.3 or higher
- Bundler

## Installation & Setup

### 1. Clone and Install Dependencies

```bash
cd flexcar_demo_project
bundle install
```

### 2. Database Setup

Configure your database credentials in `config/database.yml` or set environment variables:

```bash
export FLEXCAR_DEMO_PROJECT_DATABASE_USERNAME="postgres"
export FLEXCAR_DEMO_PROJECT_DATABASE_PASSWORD="postgres"
```

Create and migrate the database:

```bash
rails db:create
rails db:migrate
```

### 3. Install Engine Migrations

The Flexcar Promotions engine migrations should already be installed. If needed:

```bash
rails flexcar_promotions:install:migrations
rails db:migrate
```

### 4. Seed Data (Optional)

```bash
rails db:seed
```

## Running the Application

### Development Server

```bash
bin/dev
# or
rails server
```

The application will be available at `http://localhost:3000`

### Using Docker

```bash
docker build -t flexcar-demo .
docker run -p 3000:3000 flexcar-demo
```

## Testing

Run the test suite:

```bash
rails test
# or
rails test:system  # for system tests
```

## Flexcar Promotions Engine

This demo integrates the Flexcar Promotions engine located in `../flexcar_promotions`. The engine provides:

### Features
- **Multiple Item Types**: Products sold by quantity or weight
- **4 Promotion Types**:
  - Flat discount (e.g., $20 off)
  - Percentage discount (e.g., 10% off)
  - Buy X Get Y (e.g., Buy 2 get 1 free)
  - Weight threshold (e.g., 50% off when buying 100+ grams)
- **Smart Pricing**: Automatically calculates best available price
- **Time-based Promotions**: Start and end times for campaigns
- **Category & Brand Support**: Organize products and apply group promotions

### Quick Engine Demo

Run the standalone engine demo:

```bash
cd ../flexcar_promotions
bundle exec rails runner demo.rb
```

### Engine Documentation

For detailed engine documentation, see:
- `../flexcar_promotions/README.md` - Full documentation
- `../flexcar_promotions/QUICKSTART.md` - Quick start guide
- `../flexcar_promotions/INTEGRATION.md` - Integration guide
- `../flexcar_promotions/SUBMISSION.md` - Architecture overview

## Key Files & Directories

```
app/
  controllers/    # Application controllers
  models/         # Application models (extends engine models)
  views/          # Application views
config/
  routes.rb       # Application routes
  database.yml    # Database configuration
db/
  migrate/        # Database migrations (includes engine migrations)
  schema.rb       # Current database schema
```

## Configuration

### Database

Edit `config/database.yml` or use environment variables:
- `FLEXCAR_DEMO_PROJECT_DATABASE_USERNAME`
- `FLEXCAR_DEMO_PROJECT_DATABASE_PASSWORD`

### Rails Environment

Standard Rails environments are available:
- `development` - Local development (default)
- `test` - Test suite execution
- `production` - Production deployment

## Deployment

This application is configured for deployment with:

- **Kamal**: Docker-based deployment tool
- **Thruster**: HTTP asset caching and X-Sendfile acceleration

See `config/deploy.yml` for Kamal configuration.

## Development Tools

- **Brakeman**: Security vulnerability scanning (`bin/brakeman`)
- **Bundler Audit**: Gem security auditing (`bin/bundler-audit`)
- **RuboCop**: Ruby code style checking (`bin/rubocop`)

## Project Structure

This workspace contains two main components:

1. **flexcar_demo_project/** (this directory) - Rails application demonstrating engine integration
2. **flexcar_promotions/** - Reusable Rails engine for promotions

## Support & Documentation

For issues or questions about:
- The demo application: Check this README
- The promotions engine: See `../flexcar_promotions/README.md`
- Integration: See `../flexcar_promotions/INTEGRATION.md`

## License

This project is part of the Flexcar assessment.
