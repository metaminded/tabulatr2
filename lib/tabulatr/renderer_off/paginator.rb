module Tabulatr
  class Renderer
    module Paginator

      #render the paginator controls, inputs etc.
      def render_paginator
        # get the current pagination state
        if (@table_options[:paginate].is_a?(Fixnum)) && @klass.count > @table_options[:paginate] ||
          @table_options[:paginate] === true
          send(Tabulatr.bootstrap_paginator)
        end
      end

      private

      # bootstrap 3
      def create_ul_paginator
        make_tag(:ul, :class => 'pagination',
          :'data-table' => "#{@klass.to_s.downcase}_table") do
        end
      end

      # bootstrap 2
      def create_div_paginator
        make_tag(:div, :class => 'pagination',
          :'data-table' => "#{@klass.to_s.downcase}_table") do
          make_tag(:ul){}
        end
      end
    end
  end
end
