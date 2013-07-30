h1. Tabulatr - Index Tables made easy, finally

<b>Notes:</b>

<ul>
  <li>there is a <a href="https://github.com/provideal/tabulatr-demo">demo app repository</a></li>
  <li>note the spelling, it's tabulatr, not tabulat<b>o</b>r.
</ul>

h2. Mission Objective

Tabulatr aims at making the ever-recurring task of creating listings of ActiveRecord or Mongoid models simple and uniform.

We found ourselves reinventing the wheel in every project we made, by using

* different paging mechanisms,
* different ways of implementing filtering/searching,
* different ways of implementing selecting and batch actions,
* different layouts.

We finally thought that whilst gems like Formtastic or SimpleForm provide a really cool, uniform, and concise way to implement forms, it's time for a table builder. During a project with Magento, we decided that their general tables are quite reasonable, and enterprise-proven -- so that's our starting point.

h3. Visual Components

Every Tabulatr table consists of the following components:

* a wrapping form
* a 'Controls Container' containing the table-controls as
** the paginator,
** the batch_actions,
** the submit button,
** controls to manage selecting/checking/marking,
** an info_text
* The actual table consisting of
** A header row,
** A filter row,
** data rows,
** possibly a selecting/checking/marking column
** possibly action links/buttons

Whilst this is a strong decision, we made everything as-configurable-as-possible, there are roughly 150 options you can use to tweak almost every aspect of Tabulatr.

h3. Features

Tabulatr tries to make these common tasks as simple/transparent as possible:
* paging
* selecting/checking/marking
* filtering
* batch actions
* stateful index pages

h2. Example

h3. Models

We suppose we have a couple of models
* tags has and belong to many products
* vendors have many products
* products belong to vendors and have and belong to many tags

h3. Controller

In the products controllers index action we have:

<pre>
  def index
    @products = Product.find_for_table(params)
  end
</pre>

the <tt>find_for_table</tt> method is injected into ActiveRecord by Tabulatr, it retrieves all relevant data from the <tt>params</tt> hash automagically. If you want the the table to be stateful, i.e. remembering its sorting/filtering/selecting settings (very useful when processing a certain selection of entries), you can pass the option <tt>:stateful => session</tt> to the <tt>find_for_table</tt> call and the data will be stored. Also, a _Reset_ button will be rendered to get rid of the state.

h3. View

To get a simple Table, all we need to do is

<pre>
  <%= table_for @products do |t|
    t.column :id
    t.column :title
    t.column :price
    t.column :active
    t.association :vendor, :name
    t.association :tags, :title
  end %>
</pre>

but the result is pretty fancy, already:

<img src="https://github.com/provideal/tabulatr/raw/master/assets/simple_table.png" />

To add a column with checkboxes (thus giving all the "Select ..." buttons a reasonable semantics), we simply add a

<pre>
  t.checkbox
</pre>

row.

To add e.g. edit-buttons, we specify

<pre>
  t.action do |record|
    link_to "Edit", edit_product_path(record)
  end
</pre>

To add a select-popup with batch-actions (i.e., actions that are to be performed on all selected rows), we add an option to the table_for:

<pre>
  <%= table_for @products, :batch_actions => {'foo' => 'Foo', 'delete' => "Delete"} do |t|
    ...
  end %>
</pre>

To handle the actual batch action, we have to add a block to the <tt>find_for_table</tt> call in the controller:

<pre>
  @products = Product.find_for_table(params) do |batch_actions|
    batch_actions.delete do |ids|
      ids.each do |id|
        Product.find(id).destroy
      end
      redirect_to index_select_products_path()
      return
    end
    batch_actions.foo do |ids|
      ... do whatever is foo-ish to the records
    end
  end
</pre>

where the <tt>ids</tt> parameter to the block is actually an Array containing the numeric ids of the currently selected rows.

h2. Installation

Installation is pretty straightforward. Just include a line

<pre>
  gem 'tabulatr', '...current version here'
</pre>

in your applications <tt>Gemfile</tt>, then run <tt>bundle install</tt>.

Lastly, run

<pre>
  $ rails g tabulatr:install
</pre>

h2. Options


h3. Table Options

These options are to be specified at the form_for level and change the appearance and behaviour of the table. This is taken from <tt>lib/tabulatr/tabulatr/settings.rb</tt>

<pre>
  :table_class => 'tabulatr_table',               # class for the actual data table
  :control_div_class_before => 'table-controls',  # class of the upper div containing the paging and batch action controls
  :control_div_class_after => 'table-controls',   # class of the lower div containing the paging and batch action controls
  :paginator_div_class => 'pagination',            # class of the div containing the paging controls

  # which controls to be rendered above and below the tabel and in which order
  :before_table_controls => [:filter, :paginator],
  :after_table_controls => [],

  :table_html => false,              # a hash with html attributes for the table
  :row_html => false,                # a hash with html attributes for the normal trs
  :header_html => false,             # a hash with html attributes for the header trs
  :filter_html => false,             # a hash with html attributes for the filter trs
  :filter => true,                   # false for no filter row at all
  :paginate => false,                # true to show paginator
  :sortable => true,                 # true to allow sorting (can be specified for every sortable column)
  :batch_actions => false,           # :name => value hash of batch action stuff
  :footer_content => false,          # if given, add a <%= content_for <footer_content> %> before the </table>
  :path => '#'                       # where to send the AJAX-requests to
</pre>

h3. Column Options

<pre>
  :header => false,                   # a string to write into the header cell
  :width => false,                    # the width of the cell
  :align => false,                    # horizontal alignment
  :valign => false,                   # vertical alignment
  :wrap => true,                      # wraps
  :type => :string,                   # :integer, :date
  :td_html => false,                  # a hash with html attributes for the cells
  :th_html => false,                  # a hash with html attributes for the header cell
  :filter_html => false,              # a hash with html attributes for the filter cell
  :filter => true,                    # false for no filter field,
                                       # container for options_for_select
                                       # String from options_from_collection_for_select or the like
                                       # :range for range spec
                                       # :checkbox for a 0/1 valued checkbox
  :checkbox_value => '1',             # value if checkbox is checked
  :checkbox_label => '',              # text behind the checkbox
  :filter_width => '97%',             # width of the filter <input>
  :range_filter_symbol => '&ndash;',  # put between the <inputs> of the range filter
  :sortable => true,                  # if set, sorting-stuff is added to the header cell
  :format_method => nil               # javascript method to execute on this column
</pre>

h3. Global settings

These settings are *not* supposed to be changed on a per-table basis. This is necessary, because the <tt>find_for_table</tt> method needs to rely on a priori information.

h4. Table Form Options

This hash contains all the information about the naming of the generated form elements. To override them, you should, in an initializer, call

<pre>
  Tabulatr.table_form_options(my_options_hash)
</pre>

<pre>
  :pagination_postfix => '_pagination',       # name of the param w/ the pagination infos
  :filter_postfix => '_filter',               # postfix for name of the filter in the params :hash => xxx_filter
  :sort_postfix => '_sort',                   # postfix for name of the filter in the params :hash => xxx_filter
  :associations_filter => '__association',    # name of the associations in the filter hash
  :batch_postfix => '_batch',                 # postfix for name of the batch action select
  :checked_separator => ','                   # symbol to separate the checked ids
</pre>

h4. Paginate options

To override these, you should, in an initializer, call

<pre>
  Tabulatr.paginate_options(my_options_hash)
</pre>

<pre>
  page: 1,
  pagesize: 10,
  pagesizes: [10, 20, 50]
</pre>

h2. Dependencies

We use
* <a href="http://github.com/provideal/whiny_hash">whiny_hash</a> to handle the options in a fail-early-manner.

h2. Bugs

h3. Request-URI Too Large error

This is a problem particulary when using WEBrick, because WEBricks URIs must not exceed 2048 characters. And this limit is hard-coded IIRC. So – If you run into this limitation – please consider using another server. (Thanks to <a href="https://github.com/stepheneb">stepheneb</a> for calling my attention back to this.)

h3. Other, new bugs

There are roughly another 997 bugs in Tabulatr, although we do some testing (see <tt>spec/</tt>). So if you hunt them, please let me know using the <a href="https://github.com/provideal/tabulatr/issues">GitHub Bugtracker</a>.

h2. Contributing to tabulatr

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the <a href="https://github.com/provideal/tabulatr/issues">issue tracker</a> to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
* Feel free to send a pull request if you think others (me, for example) would like to have your change incorporated into future versions of tabulatr.

h2. License

Copyright (c) 2010-2011 Peter Horn, <a href="http://www.provideal.net" target="_blank">Provideal GmbH</a>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
