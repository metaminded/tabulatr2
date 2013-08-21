class Tabulatr
  def render_filter_icon
    make_tag(:a, class: 'btn btn-info', href: "#tabulatr_filter_dialog_#{@klass.to_s.downcase}",
      :'data-toggle' => 'modal'){ concat('<i class="icon-filter"></i>Filter') }
  end
end
