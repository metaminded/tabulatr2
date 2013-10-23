module Tabulatr
  class Renderer
    module FilterDialog
      def render_filter_dialog &block
        # make_tag(:div, class: 'modal fade', id: "tabulatr_filter_dialog_#{@klass.to_s.downcase}", style: "display:none ;") do
        #   make_tag(:div, class: 'modal-dialog') do
        #     make_tag(:div, class: 'modal-content') do
        #       make_tag(:div, class: 'modal-header') do
        #         make_tag(:button, class: :close, :'data-dismiss' => :modal,
        #           :'aria-hidden' => true) do
        #           concat "&times"
        #         end
        #         make_tag(:h3, class: 'modal-title') do
        #           concat I18n.t('tabulatr.filter')
        #         end
        #       end
              make_tag(:form, :'data-table' => "#{@klass.to_s.downcase}_table",
                class: 'form form-horizontal tabulatr_filter_form', :'data-remote' => true,
                role: 'form') do
                render_filter_options &block
                make_tag(:input, :type => 'submit',
                  :class => 'submit-table btn btn-primary',
                  :value => I18n.t('tabulatr.apply_filters'))
              end
      #       end # modal-content
      #     end # modal-dialog
      #   end # modal fade
      end

      def render_filter_options(&block)
        yield(filter_form_builder)
        make_tag(:input, :type => 'hidden', :name => "#{@klass.to_s.downcase}_sort")
      end
    end
  end
end
