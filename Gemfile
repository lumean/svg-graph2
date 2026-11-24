source "https://rubygems.org"

gem 'rexml'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'rubocop', require: false
end

group :test do
  gem 'bigdecimal'
  gem 'rake'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'test-unit'
  gem 'simplecov', '< 0.18', require: false # CodeClimate doesn't support 0.18
end
