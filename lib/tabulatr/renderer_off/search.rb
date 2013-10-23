module Tabulatr
  class Renderer
    module Search

      def render_search
        if(@table_options[:search])
          make_tag(:form, class: "form-inline tabulatr-fuzzy-search pull-right form-search", role: "form",
                      id: "#{@klass.to_s.downcase}_fuzzy_search",
                      :"data-table" => "#{@klass.to_s.downcase}_table") do
            make_tag(:div, class: 'form-group')do
              make_tag(:label, class: 'sr-only', for: "#{@klass.to_s.downcase}_fuzzy_search_query") do
                "search"
              end
              make_tag(:input, class: "form-control search-query", placeholder: I18n.t('tabulatr.search'),
                id: "#{@klass.to_s.downcase}_fuzzy_search_query", type: "search")
            end
          end
        end
      end

    end
  end
end
