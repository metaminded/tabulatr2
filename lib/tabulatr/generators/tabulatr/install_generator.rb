#--
# Copyright (c) 2010-2014 Peter Horn & Florian Thomas, Provideal GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Tabulatr
  module Generators
    class InstallGenerator < Rails::Generators::NamedBase
      desc "initialize tabulatr"
      source_root File.expand_path('../templates', __FILE__)
      check_class_collision suffix: 'TabulatrData'

      argument :attributes, type: :array, default: [], banner: 'field:type field:type'

      def create_tabulatr_data_file
        template 'tabulatr_data.rb', File.join('app/tabulatr_data/', class_path, "#{file_name}_tabulatr_data.rb")
      end

      def copy_initializer_file
        copy_file "tabulatr.rb", "config/initializers/tabulatr.rb"
      end

      def copy_translation_file
        copy_file "tabulatr.yml", "config/locales/tabulatr.yml"
      end

      def bootstrap
        unless yes?('Do you use Bootstrap version 3 ?')
          gsub_file 'config/initializers/tabulatr.rb', 'create_ul_paginator', 'create_div_paginator'
        end
      end

      private

      def attributes_names
        [:id] + attributes.select { |attr| !attr.reference? }.map { |a| a.name.to_sym }
      end

      def association_names
        attributes.select { |attr| attr.reference? }.map { |a| a.name.to_sym }
      end
    end
  end
end
