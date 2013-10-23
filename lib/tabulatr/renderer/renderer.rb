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
  include Tabulatr::Renderer::DataCell
  include Tabulatr::Renderer::FilterCell
  include Tabulatr::Renderer::FilterDialog
  include Tabulatr::Renderer::FilterIcon
  include Tabulatr::Renderer::BatchActions
  include Tabulatr::Renderer::Search
  include Tabulatr::Renderer::Table
  include Tabulatr::Renderer::Count


  def initialize(klass_or_record, view=nil, toptions={})
    if klass_or_record.is_a?(Class) && klass_or_record < ActiveRecord::Base
      @klass = klass_or_record
      @records = nil
    elsif klass_or_record.respond_to?(:each)
      @records = klass_or_record
      @klass = @records.first.try(:class)
      toptions = toptions.merge!(:filter => false, :paginate => false, :sortable => false)
    else
      raise "Give a model-class or an collection to `table_for'"
    end
    @view = view
    @table_options = Tabulatr::Settings::TABLE_OPTIONS.merge(toptions)
    @record = nil
    @row_mode = false
    @classname = @klass.to_s.downcase.gsub("/","_")
    @attributes = @val = []
  end

  def build_table(&block)
    return nil if @records && @records.blank?
    @val = []
    unless @records
      render_table_controls('table-controls', :before_table_controls)
    end

    render_element(:table, &block)

    unless @records
      render_table_controls('table-controls', :after_table_controls)

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
    when :search then render_search
    when :count then render_count
    when :table then render_table &block
    else
      if element.is_a?(String)
        concat(element)
      else
        raise "unknown element '#{element}'"
      end
    end
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
    if s.present? then @val << (html_escape ? h(s) : s) end
  end

  def h(s)
    ERB::Util.h(s)
  end

  def render_table_controls div_class, before_or_after
    make_tag(:div,  :class => div_class) do
      @table_options[before_or_after].each do |element|
        render_element(element)
      end
    end if @table_options[before_or_after].present? # </div>
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
end
