# Tabulatr2 - Index Tables made easy, finally

**WARNING: Tabulatr2 is not production ready yet!**

## Installation

Require tabulatr2 in your Gemfile:
```ruby
gem 'tabulatr2', require: 'tabulatr'
```
After that run `bundle` and `rails g tabulatr:install` to finish up the installation.

### Security

Tabulatr2 tries to do its best to secure your application. Specifically its secured against
an attacker who tries to change the parameters of the table and include e.g. a `password` field.

**Important:** But in order to make it so secure you have to alter the two `secret_tokens`
in your `config/initializers/tabulatr.rb` file to different values.

```ruby
Tabulatr.config do |c|
  c.secret_tokens = ['???', '???']
end
```



## Usage

### Models

We suppose we have a couple of models
* tags has and belong to many products
* vendors have many products
* products belong to vendors and have and belong to many tags

## Controller

In `ProductsController#index` we have:

<pre>
  def index
    tabulatr_for Product
  end
</pre>


### View

To get a simple Table, all we need to do is

```erb
  <%= table_for Product do |t|
    t.column :title
    t.column :price
    t.column :active
    t.association :vendor, :name
    t.association :tags, :title
  end %>
```

To add a checkbox column just add
```ruby
t.checkbox
```


To add e.g. edit-buttons, we would specify

```erb
  t.action do |record|
    link_to "Edit", edit_product_path(record.id)
  end
```

To add a select box with batch-actions (i.e., actions that are to be performed on all selected rows),
we add an option to the table_for:

```erb
  <%= table_for Product, batch_actions: {'foo' => 'Foo', 'delete' => "Delete"} do |t|
    ...
  end %>
```

To handle the actual batch action, we have to add a block to the `find_for_table` call in the controller:

```ruby
  tabulatr_for Product do |batch_actions|
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
```

where the `ids` parameter to the block is actually an Array containing the numeric ids of the currently selected rows.


## Features

Tabulatr aims at making the ever-recurring task of creating listings of ActiveRecord models simple and uniform.

We found ourselves reinventing the wheel in every project we made, by using

* different paging mechanisms,
* different ways of implementing filtering/searching,
* different ways of implementing selecting and batch actions,
* different layouts.

We finally thought that whilst gems like Formtastic or SimpleForm provide a really cool, uniform
and concise way to implement forms, it's time for a table builder.
During a project with Magento, we decided that their general tables are quite reasonable,
and enterprise-proven -- so that's our starting point.

Tabulatr tries to make these common tasks as simple/transparent as possible:
* paging
* selecting/checking/marking
* filtering
* batch actions


## Options


### Table Options

These options are to be specified at the `table_for` level and change the appearance and behaviour of the table.

```ruby
  :table_class => 'tabulatr_table',               # class for the actual data table
  :control_div_class_before => 'table-controls',  # class of upper div containing the paging and batch action controls
  :control_div_class_after => 'table-controls',   # class of lower div containing the paging and batch action controls
  :paginator_div_class => 'pagination',            # class of the div containing the paging controls

  # which controls to be rendered above and below the table and in which order
  :before_table_controls => [:filter, :paginator],
  :after_table_controls => [],

  :table_html => false,              # a hash with html attributes for the table
  :row_html => false,                # a hash with html attributes for the normal trs
  :header_html => false,             # a hash with html attributes for the header trs
  :filter_html => false,             # a hash with html attributes for the filter trs
  :filter => true,                   # false for no filter row at all
  :paginate => false,                # true to show paginator, false for endless scrolling.
                                     # number for limit of items to show via pagination
  :sortable => true,                 # true to allow sorting (can be specified for every sortable column)
  :batch_actions => false,           # :name => value hash of batch action stuff
  :footer_content => false,          # if given, add a <%= content_for <footer_content> %> before the </table>
  :path => '#'                       # where to send the AJAX-requests to
```

### Column Options

```ruby
  :header => false,                   # a string to write into the header cell
  :width => false,                    # the width of the cell
  :align => false,                    # horizontal alignment
  :valign => false,                   # vertical alignment
  :wrap => true,                      # wraps
  :type => :string,                   # :integer, :date
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
  :format_methods => []               # javascript method to execute on this column
```


## Dependencies

We use [whiny_hash](http://github.com/provideal/whiny_hash) to handle the options in a fail-early-manner.

## Known Bugs

### Request-URI Too Large error

This is a problem particulary when using WEBrick, because WEBricks URIs must not exceed 2048 characters.
And this limit is hard-coded IIRC. So – If you run into this limitation –
please consider using another server.
(Thanks to [stepheneb](https://github.com/stepheneb) for calling my attention back to this.)

## Other, new bugs

There are roughly another 997 bugs in Tabulatr2, although we do some testing.
If you hunt them, please file an issue.

## Contributing

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the Issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it, run them via `rspec spec` and check that they all pass.
* Please try not to mess with the Rakefile, version, or history.
  If you want to have your own version, or is otherwise necessary, that is fine,
  but please isolate to its own commit so I can cherry-pick around it.
* Feel free to send a pull request if you think others (me, for example) would like to have your change
  incorporated into future versions of tabulatr.

## MIT License

Copyright (c) 2010-2013 Peter Horn, Provideal GmbH</a>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
