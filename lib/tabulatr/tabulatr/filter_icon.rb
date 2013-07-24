class Tabulatr
  def render_filter_icon
    make_tag(:a, class: 'icon-filter', href: '#tabulatr_filter_diialog',
      :'data-toggle' => 'modal'){}
  end
end
