module Tabulatr
  class Renderer
    module Table
      def render_table(&block)
        to = @table_options[:table_html]
        table_id = "#{@klass.to_s.downcase}_table"
        to = (to || {}).merge(:class => "tabulatr_table table",
          :'data-path' => @table_options[:path], :id => table_id)
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
        end # </table>
        make_tag(:span, class: 'pagination_trigger', :'data-table' => table_id){}
      end

      # render the header row
      def render_table_header(&block)
        make_tag(:tr, @table_options[:header_html]) do
          yield(header_row_builder)
        end # </tr>"
      end

      # render the table rows, only used if records are passed
      def render_table_rows(&block)
        @records.each_with_index do |record, i|
          rc = nil
          make_tag(:tr, :class => rc, :id => dom_id(record)) do
            yield(data_row_builder(record))
          end # </tr>
        end
      end

       def render_empty_start_row(&block)
        make_tag(:tr, class: 'empty_row') do
          yield empty_row_builder
        end
      end
    end
  end
end
