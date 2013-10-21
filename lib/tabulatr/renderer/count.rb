module Tabulatr
  class Renderer
    module Count
      def render_count
        make_tag(:div, class: "tabulatr_count",
          :'data-table' => "#{@klass.to_s.downcase}_table",
          :'data-format-string' => I18n.t('tabulatr.count')){}
      end
    end
  end
end
