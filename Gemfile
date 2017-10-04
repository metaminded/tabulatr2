source 'https://rubygems.org'

gemspec

gem 'jquery-rails'
gem 'turbolinks'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller', platforms: :ruby
end

group :test do
  gem 'simplecov', :require => false
end


group :development, :test do
  if defined?(JRUBY_VERSION)
    gem 'activerecord-jdbc-adapter'
    gem 'jdbc-sqlite3'
  else
    gem 'sqlite3'
  end
  gem 'minitest'
  gem 'launchy'
  gem 'database_cleaner', '< 1.1.0'
  gem 'poltergeist'
  gem 'sass-rails', '~> 4.0.0', '>= 4.0.2'
  gem 'bootstrap-sass', '~> 3.0.3.0'
end
