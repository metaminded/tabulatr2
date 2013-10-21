module ActiveModel
  class Railtie < Rails::Railtie
    initializer 'generators' do |app|
      require 'rails/generators'
      require 'tabulatr/generators/tabulatr/install_generator'
      Rails::Generators.configure!(app.config.generators)
      require 'tabulatr/generators/resource_override'
    end
  end
end
