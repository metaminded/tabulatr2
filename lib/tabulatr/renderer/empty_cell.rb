module Tabulatr
  class Renderer
    module EmptyCell

      def empty_column(name, opts={}, &block)
        raise "Not in empty mode!" if @row_mode != :empty
        opts = normalize_column_options(name, opts)
        make_tag(:td, opts[:filter_html])
      end
    end
  end
end
