require 'rails/generators'
require 'rails/generators/rails/resource/resource_generator'

module Rails
  module Generators
    class ResourceGenerator
      def add_tabulatr_data
        invoke 'tabulatr:install'
      end
    end
  end
end
