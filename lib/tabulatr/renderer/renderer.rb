class Tabulatr::Renderer

  def initialize(klass, view,
      filter: true,          # false for no filter row at all
      search: true,          # show fuzzy search field
      paginate: false,       # true to show paginator
      pagesize: 20,          # default pagesize
      sortable: true,        # true to allow sorting (can be specified for every sortable column)
      batch_actions: false,  # :name => value hash of batch action stuff
      footer_content: false, # if given, add a <%= content_for <footer_content> %> before the </table>
      path: '#')             # where to send the AJAX-requests to
    @klass = klass
    @view = view
    @table_options = {
      filter: filter,
      search: search,
      paginate: paginate,
      pagesize: pagesize,
      sortable: sortable,
      batch_actions: batch_actions,
      footer_content: footer_content,
      path: path
    }
    @classname = @klass.name.underscore
  end

  def build_table(&block)
    @columns = ColumnsFromBlock.process @klass, &block

    @view.render(partial: '/tabulatr/tabulatr_table', locals: {
      columns: @columns,
      table_options: @table_options,
      klass: @klass,
      classname: @classname
    })
  end

  def build_static_table(records, &block)
    @columns = ColumnsFromBlock.process @klass, &block

    @view.render(partial: '/tabulatr/tabulatr_static_table', locals: {
      columns: @columns,
      table_options: @table_options,
      klass: @klass,
      classname: @classname,
      records: records
    })
  end

  def self.build_static_table(records, view, toptions={}, &block)
    return '' unless records.present?
    klass = records.first.class
    new(klass, view, toptions).build_static_table(records, &block)
  end

  def self.build_table(klass, view, toptions={}, &block)
    new(klass, view, toptions).build_table(&block)
  end

end

require_relative './column'
require_relative './association'
require_relative './action'
require_relative './checkbox'
require_relative './columns'
require_relative './columns_from_block'

