source "https://rubygems.org"

# Specify the Ruby version
ruby "3.1.2"

# Rails framework
gem "rails", "~> 7.1.3", ">= 7.1.3.3"

# The original asset pipeline for Rails (manages assets like CSS, JS)
gem "sprockets-rails"

# PostgreSQL as the database for Active Record
gem "pg", "~> 1.1"

# Puma web server for production
gem "puma", ">= 5.0"

# JavaScript with ESM import maps
gem "importmap-rails", "~> 1.2.3"

# Geocoding library to handle geolocation and address lookups
gem "geocoder"

# Validations for Active Storage (e.g., file attachments)
gem 'active_storage_validations'

# Hotwire SPA-like functionality (Turbo & Stimulus)
gem "turbo-rails"
gem "stimulus-rails"

# Build JSON APIs with ease
gem "jbuilder"

# Redis adapter for Action Cable (WebSockets)
gem "redis", ">= 4.0.1"

# User authentication system
gem "devise"

# Cloudinary integration for image and video hosting
gem "cloudinary"

# Platform-specific gem to handle timezone data
gem "tzinfo-data", platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Speed up boot times through caching
gem "bootsnap", require: false

# Bootstrap CSS framework
gem "bootstrap", "~> 5.2"

# Auto-prefixer for adding vendor prefixes to CSS rules
gem "autoprefixer-rails"

# Font Awesome for icons
gem "font-awesome-sass", "~> 6.1"

# SimpleForm for generating forms easily
gem "simple_form", github: "heartcombo/simple_form"

# SassC for compiling Sass to CSS
gem "sassc-rails"

# Gemfile
gem 'activerecord-postgis-adapter', '~> 9.0'
gem 'rgeo', '~> 2.3'
gem 'rgeo-activerecord', '~> 7.0'

# Gemfile
gem 'httparty'

gem 'kaminari'

gem 'sidekiq'


# Group for development and test environments
group :development, :test do
  # Dotenv for loading environment variables from .env
  gem "dotenv-rails"

  # Debugging tools for Rails
  gem "debug", platforms: %i[mri mswin mswin64 mingw x64_mingw]
end

# Group specifically for development
group :development do
  # Console on exceptions pages
  gem "web-console"

  # Highlight errors in development
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

# Group specifically for testing
group :test do
  # System testing tools
  gem "capybara"
  gem "selenium-webdriver"

  # Database cleaner to ensure a clean state between tests
  gem 'database_cleaner-active_record'
end

# Group specifically for production
group :production do
  # Manages static assets and logging for Heroku
  gem 'rails_12factor'
end
