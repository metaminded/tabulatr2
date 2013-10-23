module Tabulatr
  class Renderer
    module FilterCell

      def filter_column(name, opts={}, &block)
        raise "Not in filter mode!" if @row_mode != :filter
        opts = normalize_column_options(name, opts)
        of = opts[:filter]
        iname = "#{@classname}_filter[#{name}]"
        filter_name = "tabulatr_form_#{name}"
        build_filter(of, filter_name, name, iname, opts) if filterable?(of, name.to_s)
      end

      def filter_association(relation, name, opts={}, &block)
        raise "Not in filter mode!" if @row_mode != :filter
        opts = normalize_column_options(name, opts)

        of = opts[:filter]
        iname = "#{@classname}_filter[__association][#{relation}.#{name}]"
        filter_name = "tabulatr_form_#{relation}_#{name}"
        build_filter(of, filter_name, name, iname, opts, relation) if filterable?(of, name.to_s, relation)
      end

      def filter_checkbox(opts={}, &block)
        raise "Whatever that's for!" if block_given?
        make_tag(:td, opts[:filter_html]) {}
      end

      def filter_action(opts={}, &block)
        raise "Not in filter mode!" if @row_mode != :filter
        opts = normalize_column_options(:action_column, opts)
        make_tag(:td, opts[:filter_html]) do
          concat(t(opts[:filter])) unless [true, false, nil].member?(opts[:filter])
        end # </td>
      end

    private

      def filter_tag(of, name, iname, attr_name, opts)
        if !of
          ""
        elsif of.is_a?(Hash) or of.is_a?(Array) or of.is_a?(String)
          make_tag(:select,
            :id => name, name: iname) do
            if of.class.is_a?(String)
              concat(of)
            else
              concat("<option></option>")
              t = options_for_select(of)
              concat(t.sub("value=\"\"", "value=\"\" selected=\"selected\""))
            end
          end # </select>
        elsif opts[:filter] == :range
          filter_text_tag("#{name}_from", iname, attr_name, 'from')
          concat(opts[:range_filter_symbol])
          filter_text_tag("#{name}_to", iname, attr_name, 'to')
        elsif opts[:filter] == :checkbox
          checkbox_value = opts[:checkbox_value]
          checkbox_label = opts[:checkbox_label]
          concat(check_box_tag(iname, checkbox_value, false, {}))
          concat(checkbox_label)
        elsif opts[:filter] == :exact
          filter_text_tag(name, iname, attr_name, 'normal')
        else
          filter_text_tag(name, iname, attr_name, 'like')
        end # if
      end

      def filter_text_tag name, iname, attr_name, type=nil
        name_attribute = iname
        name_attribute += "[#{type}]" if type && type != 'normal'
        make_tag(:input, :type => :text, :id => name,
            :value => '',
            :'data-type' => type,
            :'data-tabulatr-attribute' => attr_name,
            :class => 'tabulatr_filter',
            :name => name_attribute)
      end

      def build_filter(of, filter_name, name, iname, opts, relation=nil)
        if of
          make_tag(:div, class: 'control-group form-group', 'data-filter-column-name' => name) do
            make_tag(:label, class: 'control-label col-md-3', for: filter_name) do
              concat(t(opts[:header] || readable_name_for(name, relation)), :escape_html)
            end
            make_tag(:div, class: 'controls col-md-9') do
              filter_tag(of, filter_name, iname, name, opts)
            end
          end
        end
      end

      def filterable?(of, name, relation=nil)
       of && (!(relation && name.to_sym == :count))
      end
    end
  end
end
