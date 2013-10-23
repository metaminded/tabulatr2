module Tabulatr
  class Renderer
    module BatchActions

      # render the select tag or the buttons for batch actions
      def render_batch_actions
        iname = "#{@classname}_batch"
        make_tag(:span, :class => 'dropdown') do
          make_tag(:button,
                    :class => 'disabled btn btn-small tabulatr-wrench',
                    :'data-toggle' => "dropdown") do
            concat("<i class='icon-wrench'></i>#{I18n.t('tabulatr.batch_actions')}
                    <span class='caret'></span>")
          end
          make_tag(:ul, class: 'dropdown-menu', role: 'menu',
                    :'aria-labelledby' => 'dLabel') do
            @table_options[:batch_actions].each do |n,v|
              make_tag(:li) do
                make_tag(:a, :value => v,
                  :name => "#{iname}[#{n}]",
                  :class => "btn batch-action-inputs") do
                  concat(v)
                end
              end
            end
          end
        end
      end
    end
  end
end
