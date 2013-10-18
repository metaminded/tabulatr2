module Tabulatr
  class Renderer
    module HeaderCell


      # the method used to actually define the headers of the columns,
      # taking the name of the attribute and a hash of options.
      #
      # The following options are evaluated here:
      # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
      # <tt>:header</tt>:: if present, the value will be output in the header cell,
      #                    otherwise, the capitalized name is used
      def header_column(name, opts={}, &block)
        raise "Not in header mode!" if @row_mode != :header
        sortparam = "#{@classname}_sort"
        filter_name = "#{@classname}_filter[#{name}]"
        bid = "#{@classname}_sort"

        create_header_tag(name, opts, sortparam, filter_name, name,
          nil, bid
        )
      end

      # the method used to actually define the headers of the columns,
      # taking the name of the attribute and a hash of options.
      #
      # The following options are evaluated here:
      # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
      # <tt>:header</tt>:: if present, the value will be output in the header cell,
      #                    otherwise, the capitalized name is used
      def header_association(relation, name, opts={}, &block)
        raise "Not in header mode!" if @row_mode != :header
        if @klass.reflect_on_association(relation.to_sym).collection?
          opts[:sortable] = false
        end
        create_header_tag(name, opts,
          "#{@classname}_sort[#{relation.to_s}.#{name.to_s}]",
          "#{@classname}_filter[__association][#{relation.to_s}.#{name.to_s}]",
          "#{relation}:#{name}",
          relation
        )
      end

      def header_checkbox(opts={}, &block)
        raise "Whatever that's for!" if block_given?
        opts = normalize_column_options(:checkbox_column, opts)
        opts = normalize_header_column_options opts, :checkbox
        make_tag(:th, opts[:th_html]) do
          make_tag(:input, type: 'checkbox', :'data-table' => "#{@klass.to_s.downcase}_table",
            class: "tabulatr_mark_all"){}
          render_batch_actions if @table_options[:batch_actions]
        end
      end

      def header_action(opts={}, &block)
        raise "Please specify a block" unless block_given?
        opts = normalize_column_options(:action_column, opts)
        opts = normalize_header_column_options opts, :action
        dummy = Tabulatr::DummyRecord.for(@klass)
        cont = yield(dummy)
        cont = cont.join(' ') if cont.is_a? Array
        opts[:th_html]['data-tabulatr-action'] = cont.gsub('"', "'")
        @attributes = (@attributes + dummy.requested_methods).flatten
        names = dummy.requested_methods.join(',')

        make_tag(:th, opts[:th_html].merge('data-tabulatr-column-name' => names)) do
          concat(t(opts[:header] || ""), :escape_html)
        end
      end

      private

      def normalize_header_column_options opts, type=nil
        opts[:th_html] ||= {}
        opts[:th_html]['data-tabulatr-column-type'] = type if type
        if opts[:format_methods]
          opts[:th_html]['data-tabulatr-methods'] = opts[:format_methods].join(',')
        end
        opts
      end

      def create_sorting_elements opts, sortparam, name, bid=""
        if opts[:sortable] and @table_options[:sortable]
          if @sorting and @sorting[:by].to_s == name.to_s
            pname = "#{sortparam}[_resort][#{name}]"
            bid = "#{bid}_#{name}"
            sort_dir = @sorting[:direction] == 'asc' ? 'desc' : 'asc'
            make_tag(:input, :type => :hidden,
              :name => "#{sortparam}[#{name}][#{@sorting[:direction]}]",
              :value => "#{@sorting[:direction]}")
          else
            pname = "#{sortparam}[_resort][#{name}]"
            bid = "#{bid}_#{name}"
            sort_dir = 'asc'
          end
          make_sort_icon(:id => bid, :name => pname, :'data-sort' => sort_dir)
        end
      end

        def make_sort_icon(options)
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


      def create_header_tag name, opts, sort_param, filter_name, column_name, relation=nil, bid=nil
        opts = normalize_column_options(name, opts)
        opts = normalize_header_column_options(opts)
        opts[:th_html]['data-tabulatr-column-name'] = column_name
        opts[:th_html]['data-tabulatr-form-name'] = filter_name
        opts[:th_html]['data-tabulatr-sorting-name'] = sorting_name(name, relation)
        make_tag(:th, opts[:th_html]) do
          concat(t(opts[:header] || readable_name_for(name, relation)), :escape_html)
          create_sorting_elements(opts, sort_param, name, bid) unless relation && name.to_sym == :count
        end # </th>
      end

      def sorting_name name, relation=nil
        return "#{@klass.reflect_on_association(relation).klass.name.downcase}.#{name}" if relation && @klass.reflect_on_association(relation).klass.column_names.include?(name.to_s)
        return "#{@klass.name.downcase}.#{name}" if @klass.column_names.include?(name.to_s)
        name
      end
    end
  end
end
