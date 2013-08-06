#--
# Copyright (c) 2010-2011 Peter Horn, Provideal GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# Tabulatr is a class to allow easy creation of data tables as you
# frequently find them on 'index' pages in rails. The 'table convention'
# here is that we consider every table to consist of three parts:
# * a header containing the names of the attribute of the column
# * a filter which is an input element to allow for searching the
#   particular attribute
# * the rows with the actual data.
#
# Additionally, we expect that people want to 'select' rows and perform
# batch actions on these rows.
#
# Author::    Peter Horn, (mailto:peter.horn@provideal.net)
# Copyright:: Copyright (c) 2010-2011 by Provideal GmbH (http://www.provideal.net)
# License::   MIT Licence
class Tabulatr

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::RecordTagHelper
#  include ActionView::Helpers::AssetTagHelper
#  include Rails::Application::Configurable

  # Constructor of Tabulatr
  #
  # Parameters:
  # <tt>klass</tt>:: the klass of the data for the table
  # <tt>view</tt>:: the current instance of ActionView
  # <tt>opts</tt>:: a hash of options specific for this table
  def initialize(klass, view=nil, toptions={})
    @klass = klass
    @view = view
    @table_options = TABLE_OPTIONS.merge(toptions)
    @table_form_options = TABLE_FORM_OPTIONS
    @val = []
    @record = nil
    @row_mode = false
    @classname = klass.to_s.downcase.gsub("/","_")
    @attributes = []
  end

  def self.config &block
    yield
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
    @val = []
    # TODO: make_tag(:input, :type => 'submit', :style => 'display:inline; width:1px; height:1px', :value => '__submit')
    make_tag(:div,  :class => @table_options[:control_div_class_before]) do
      @table_options[:before_table_controls].each do |element|
        render_element(element)
      end
    end if @table_options[:before_table_controls].present? # </div>

    render_element(:table, &block)

    make_tag(:div,  :class => @table_options[:control_div_class_after]) do
      @table_options[:after_table_controls].each do |element|
        render_element(element)
      end
    end if @table_options[:after_table_controls].present? # </div>

    make_tag(:div, id: 'tabulatr_count', :'data-format-string' => I18n.t('tabulatr.count')){}

    make_tag(:div, class: :modal, id: 'tabulatr_filter_dialog', style: "display:none ;") do
      make_tag(:button, class: :close, :'data-dismiss' => :modal,
        :'aria-hidden' => true) do
        concat "&times"
      end
      make_tag(:h3) do
        concat I18n.t('tabulatr.filter')
      end
      make_tag(:form, id: 'tabulatr_filter_form', class: 'form-horizontal', :'data-remote' => true) do
        make_tag(:div, class: 'modal-body') do
          render_filter_options &block
        end
        make_tag(:div, class: 'modal-footer') do
          make_tag(:input, :type => 'submit', :id => 'tabulatr_filter_form_submit',
            :class => 'submit-table btn btn-primary',
            :value => I18n.t('tabulatr.apply_filters'))
        end
      end
    end
    sec_hash = Tabulatr::Security.sign(@attributes.join(','))
    make_tag(:span, :id => 'tabulatr_security', :'data-salt' => sec_hash.split('-')[1], :'data-hash' => sec_hash.split('-')[2]){}
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
      :'data-path' => @table_options[:path])
    make_tag(:table, to) do
      make_tag(:thead) do
        render_table_header(&block)
      end # </thead>
      make_tag(:tbody) do
        render_empty_start_row(&block)
      end # </tbody>
      content_for(@table_options[:footer_content]) if @table_options[:footer_content]
    end # </table>
  end

private
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
      make_tag(:input, :type => 'hidden', :name => 'sort_by')
      make_tag(:input, :type => 'hidden', :name => 'orientation')
  end

  def render_empty_start_row(&block)
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
      icon_class = 'icon-arrow-down'
    else
      icon_class = 'icon-arrow-up'
    end
    if !inactive
      make_tag(:i,
        options.merge(
          :class => "tabulatr-sort #{icon_class}"
        )
      )
    else
      make_tag(:i, :class => "tabulatr-sort #{icon_class}")
    end
  end

  def self.config(&block)
    yield(self)
  end

end

Dir[File.join(File.dirname(__FILE__), "tabulatr", "*.rb")].each do |file|
  require file
end
