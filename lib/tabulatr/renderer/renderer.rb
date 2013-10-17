class Tabulatr::Renderer

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::RecordTagHelper

  include Tabulatr::Renderer::Paginator
  include Tabulatr::Renderer::RowBuilder
  include Tabulatr::Renderer::HeaderCell
  include Tabulatr::Renderer::EmptyCell
  include Tabulatr::Renderer::FilterCell
  include Tabulatr::Renderer::FilterIcon
  include Tabulatr::Renderer::BatchActions
#  include ActionView::Helpers::AssetTagHelper
#  include Rails::Application::Configurable

  # Constructor of Tabulatr
  #
  # Parameters:
  # <tt>klass</tt>:: the klass of the data for the table
  # <tt>view</tt>:: the current instance of ActionView
  # <tt>opts</tt>:: a hash of options specific for this table
  def initialize(klass_or_record, view=nil, toptions={})
    if klass_or_record.is_a?(Class) && klass_or_record < ActiveRecord::Base
      @klass = klass_or_record
      @records = nil
    elsif klass_or_record.respond_to?(:each)
      @records = klass_or_record
      @klass = @records.first.try(:class)
      toptions = toptions.merge! \
        :filter => false,
        :paginate => false,
        :sortable => false
    else
      raise "Give a model-class or an collection to `table_for'"
    end
    @view = view
    @table_options = Tabulatr::Settings::TABLE_OPTIONS.merge(toptions)
    @val = []
    @record = nil
    @row_mode = false
    @classname = @klass.to_s.downcase.gsub("/","_")
    @attributes = []
  end

  cattr_accessor :bootstrap_paginator, instance_accessor: false do
    'create_ul_paginator'
  end

  def self.config &block
    yield self
  end

  def self.secret_tokens=(secret_tokens)
    @@secret_tokens = secret_tokens
  end

  def self.secret_tokens
    @@secret_tokens ||= []
  end

  # the actual table definition method. It takes an Array of records, a hash of
  # options and a block with the actual <tt>column</tt> calls.
  #
  # The following options are evaluated here:
  # <tt>:table_html</tt>:: a hash with html-attributes added to the <table> created
  # <tt>:header_html</tt>:: a hash with html-attributes added to the <tr> created
  #                         for the header row
  # <tt>:filter_html</tt>:: a hash with html-attributes added to the <tr> created
  #                         for the filter row
  # <tt>:row_html</tt>:: a hash with html-attributes added to the <tr>s created
  #                      for the data rows
  # <tt>:filter</tt>:: if set to false, no filter row is output
  def build_table(&block)
    return nil if @records && @records.blank?
    @val = []
    # TODO: make_tag(:input, :type => 'submit', :style => 'display:inline; width:1px; height:1px', :value => '__submit')
    unless @records
      render_table_controls(:control_div_class_before, :before_table_controls)
    end

    render_element(:table, &block)

    unless @records
      render_table_controls(:control_div_class_after, :after_table_controls)
      make_tag(:div, class: "tabulatr_count",
        :'data-table' => "#{@klass.to_s.downcase}_table",
        :'data-format-string' => I18n.t('tabulatr.count')){}

      render_filter_dialog &block
      sec_hash = Tabulatr::Security.sign(@attributes.join(','))
      make_tag(:span, :id => "tabulatr_security_#{@klass.to_s.downcase}",
        :'data-salt' => sec_hash.split('-')[1],
        :'data-hash' => sec_hash.split('-')[2]){}
    end
    @val.join("").html_safe
  end

  def render_element(element, &block)
    case element
    when :filter then render_filter_icon
    when :paginator then render_paginator
    when :table then render_table &block
    else
      if element.is_a?(String)
        concat(element)
      else
        raise "unknown element '#{element}'"
      end
    end
  end


  def render_table(&block)
    to = @table_options[:table_html]
    to = (to || {}).merge(:class => "#{@table_options[:table_class]} table",
      :'data-path' => @table_options[:path], :id => "#{@klass.to_s.downcase}_table")
    make_tag(:table, to) do
      make_tag(:thead) do
        render_table_header(&block)
      end # </thead>
      if @records
        make_tag(:tbody) do
          render_table_rows(&block)
        end # </tbody>
      else
        make_tag(:tbody) do
          render_empty_start_row(&block)
        end # </tbody>
      end
      content_for(@table_options[:footer_content]) if @table_options[:footer_content]
    end # </table>
  end

private

  def readable_name_for(name, relation=nil)
    if relation
      "#{@klass.human_attribute_name(relation).titlecase}
       #{@klass.reflect_on_association(relation).klass.
          human_attribute_name(name).titlecase}"
    else
      @klass.human_attribute_name(name).titlecase
    end
  end

  # either append to the internal string buffer or use
  # ActionView#concat to output if an instance is available.
  def concat(s, html_escape=false)
    #@view.concat(s) if (Rails.version.to_f < 3.0 && @view)
    #puts "\##{Rails.version.to_f} '#{s}'"
    if s.present? then @val << (html_escape ? h(s) : s) end
  end

  def h(s)
    ERB::Util.h(s)
  end

  def t(s)
    return '' unless s.present?
    begin
      if s.respond_to?(:should_localize?) and s.should_localize?
        translate(s)
      else
        case @should_translate
        when :translate then translate(s)
        when true then translate(s)
        when :localize then localize(s)
        else
          if !@should_translate
            s
          elsif @should_translate.respond_to?(:call)
            @should_translate.call(s)
          else
            raise "Wrong value '#{@should_translate}' for table option ':translate', should be false, true, :translate, :localize or a proc."
          end
        end
      end
    rescue
      raise "Translating '#{s}' failed!"
    end
  end

  # render the header row
  def render_table_header(&block)
    make_tag(:tr, @table_options[:header_html]) do
      yield(header_row_builder)
    end # </tr>"
  end


  def render_filter_options(&block)
      yield(filter_form_builder)
      make_tag(:input, :type => 'hidden', :name => "#{@klass.to_s.downcase}_sort")
  end

  def render_empty_start_row(&block)
    row_html = @table_options[:row_html] || {}
    row_html[:class] = 'empty_row'
    make_tag(:tr, row_html) do
      yield empty_row_builder
    end
  end

  def render_table_controls div_class, before_or_after
    make_tag(:div,  :class => @table_options[div_class]) do
      @table_options[before_or_after].each do |element|
        render_element(element)
      end
    end if @table_options[before_or_after].present? # </div>
  end

  def render_filter_dialog &block
    make_tag(:div, class: 'modal fade', id: "tabulatr_filter_dialog_#{@klass.to_s.downcase}", style: "display:none ;") do
      make_tag(:div, class: 'modal-dialog') do
        make_tag(:div, class: 'modal-content') do
          make_tag(:div, class: 'modal-header') do
            make_tag(:button, class: :close, :'data-dismiss' => :modal,
              :'aria-hidden' => true) do
              concat "&times"
            end
            make_tag(:h3, class: 'modal-title') do
              concat I18n.t('tabulatr.filter')
            end
          end
          make_tag(:form, :'data-table' => "#{@klass.to_s.downcase}_table",
            class: 'form-horizontal tabulatr_filter_form', :'data-remote' => true) do
            make_tag(:div, class: 'modal-body') do
              render_filter_options &block
            end
            make_tag(:div, class: 'modal-footer') do
              make_tag(:input, :type => 'submit',
                :class => 'submit-table btn btn-primary',
                :value => I18n.t('tabulatr.apply_filters'))
            end
          end
        end # modal-content
      end # modal-dialog
    end # modal fade
  end

  # render the table rows, only used if records are passed
  def render_table_rows(&block)
    #   row_classes = @table_options[:row_classes] || []
    #   row_html = @table_options[:row_html] || {}
    #   row_class = row_html[:class] || ""
    @records.each_with_index do |record, i|
      #concat("<!-- Row #{i} -->")
      # if row_classes.present?
      #   rc = row_class.present? ? row_class + " " : ''
      #   rc += row_classes[i % row_classes.length]
      # else
      #   rc = nil
      # end
      rc = nil
      make_tag(:tr, :class => rc, :id => dom_id(record)) do
        yield(data_row_builder(record))
      end # </tr>
    end
  end

  def render_table_row(&block)
    row_html = @table_options[:row_html] || {}
    row_html[:class] = 'empty_row'
    make_tag(:tr, row_html) do
      yield empty_row_builder
    end
  end


  # stringly produce a tag w/ some options
  def make_tag(name, hash={}, &block)
    attrs = hash ? tag_options(hash) : ''
    if block_given?
      if name
        concat("<#{name}#{attrs}>")
        yield
        concat("</#{name}>")
      else
        yield
      end
    else
      concat("<#{name}#{attrs} />")
    end
    nil
  end

  def make_image_button(options)
    inactive = options.delete(:inactive)
    if(options['data-sort'] == 'desc')
      icon_class = 'glyphicon glyphicon-arrow-down icon-arrow-down'
    else
      icon_class = 'glyphicon glyphicon-arrow-up icon-arrow-up'
    end
    if !inactive
      make_tag(:span,
        options.merge(
          :class => "tabulatr-sort #{icon_class}"
        )
      )
    else
      make_tag(:span, :class => "tabulatr-sort #{icon_class}")
    end
  end
end
# Dir[File.join(File.dirname(__FILE__), "tabulatr", "*.rb")].each do |file|
#   require file
# end
# require File.join(File.dirname(__FILE__), "tabulatr", "data", "data.rb")
