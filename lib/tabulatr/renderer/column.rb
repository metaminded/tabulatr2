class Tabulatr::Renderer::Column
  include ActiveModel::Model

  attr_accessor *%i{name header width align valign wrap type th_html filter_html
    filter checkbox_value checkbox_label filter_width range_filter_symbol
    sortable format_methods table_name block klass format map}

  def self.from(
    name: nil,
    table_name: nil,
    header: false,
    width: false,
    align: false,
    valign: false,
    wrap: true,
    type: :string,
    th_html: false,
    filter_html: false,
    filter: true,
    checkbox_value: '1',
    checkbox_label: '',
    sortable: true,
    format: nil,
    map: true,
    klass: nil,
    &block)
    b = block_given? ? block : nil
    self.new(
      name: name,
      table_name: table_name,
      header: header,
      width: width,
      align: align,
      valign: valign,
      wrap: wrap,
      type: type,
      th_html: th_html,
      filter_html: filter_html,
      filter: filter,
      checkbox_value: checkbox_value,
      checkbox_label: checkbox_label,
      sortable: sortable,
      format: format,
      map: map,
      klass: klass,
      block: b
    )
  end

  def klassname() @_klassname ||= @klass.name.underscore end
  def human_name() header || klass.human_attribute_name(name) end
  def sort_param() "#{klassname}_sort" end
  def full_name() [table_name, name].compact.join(":") end
  def coltype() 'column' end

  def column?() true end
  def association?() false end
  def checkbox?() false end
  def action?() false end

  def value_for(record, view)
    if block
      return view.instance_exec(record, &block)
    end
    val = principal_value(record) or return ''

    if format.present? && val.respond_to?(:to_a)
      val.map do |v|
        case format
        when Symbol then view.send(format, v)
        when String then format % v
        when Proc   then format.(v)
        else val
        end
      end
    elsif format.present?
      case format
      when Symbol then view.send(format, val)
      when String then format % val
      when Proc   then format.(val)
      else val
      end
    end
  end

  def principal_value(record)
    record.send name
  end

end
