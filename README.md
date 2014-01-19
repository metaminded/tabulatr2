# Tabulatr2 - Index Tables made easy
[![Gem Version](https://badge.fury.io/rb/tabulatr2.png)](http://badge.fury.io/rb/tabulatr2)
[![Code Climate](https://codeclimate.com/github/provideal/tabulatr2.png)](https://codeclimate.com/github/provideal/tabulatr2)
[![Travis CI](https://api.travis-ci.org/provideal/tabulatr2.png)](https://travis-ci.org/provideal/tabulatr2)

## Installation

Require tabulatr2 in your Gemfile:
```ruby
gem 'tabulatr2'
```
After that run `bundle install`.

Also add `//= require tabulatr` to your application js file and `*= require tabulatr` to your CSS asset
pipeline.

Now run the Install generator via
`rails g tabulatr install`

## Usage

### Models

We suppose we have these three models:
```ruby
class Tag < ActiveRecord::Base
  has_and_belongs_to_many :products
end
```
```ruby
class Product < ActiveRecord::Base
  belongs_to :vendor
  has_and_belongs_to_many :tags
end
```
```ruby
class Vendor < ActiveRecord::Base
  has_many :products
end
```

and we want to display information about products in the `ProductsController#index` action.

## ProductTabulatrData

In this class we define which information should be available for the table and how it is formatted.
```ruby
class ProductTabulatrData < Tabulatr::Data

  search :vendor_address, :title

  # search do |query|
  #   "products.title LIKE '#{query}'"
  # end

  column :id
  column :title { title.capitalize }
  column :price do "#{price} EUR" end
  column :vendor_address, sort_sql: "vendors.zipcode || '' || vendors.city",
                        filter_sql: "vendors.street || '' || vendors.zipcode || '' vendors.city" do
         "#{vendor.house_number} #{vendor.street}, #{vendor.zipcode} #{vendor.city}"
  end
  column :edit_link do
    link_to "edit #{title}", product_path(id)
  end
  column :updated_at do
    "#{updated_at.strftime('%H:%M %Y/%m/%d')}"
  end
  association :vendor, :name
  association :tags, :title do "'#{tags.map(&:title).map(&:upcase).join(', ')}'" end

end
```
The search method is used for a fuzzy search field.

You can automatically generate a new TabulatrData-Class by running
`rails g tabulatr:table MODELNAME`.

This will generate a `MODELNAMETabulatrData` class in `app/tabulatr_data/MODELNAME_data.rb` for you.

This generator also gets executed if you just run the standard Rails `resource` generator.

## Controller

In `ProductsController#index` we have:

```ruby
  def index
    tabulatr_for Product
  end
```

_Hint:_ If you want to prefilter your table, you can do that too! Just pass an `ActiveRecord::Relation` to `tabulatr_for`:
```ruby
  def index
    tabulatr_for Product.where(active: true)
  end
```

### View

In the view we can use all the attributes which are defined in our `ProductTabulatrData` class.
To display all the columns defined in the `ProductTabulatrData` class we
just need to put the following statement in our view:

```erb
<%= table_for Product %>
```
If you just want do display a subset of the defined columns or show them in a
different order you can provide them as arguments to the `columns` key:

```erb
<%= table_for Product, columns: [:vendor_address, 'vendor:name', {tags: :title}]%>
```
Note that you can write associations as a string with colon between association
name and method or as a hash as you can see above.

An other option is to provide the columns in a block:

```erb
  <%= table_for Product do |t|
    t.column :title
    t.column :price
    t.association :vendor, :name
    t.column :vendor_address
    t.column :updated_at
    t.association :tags, :title
    t.column :edit_link
  end %>
```

To add a checkbox column just add
```erb
t.checkbox
```

To add a select box with batch-actions (actions that should be performed on all selected rows),
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

These options should be specified at the view level as parameters to the `table_for` call.
They change the appearance and behaviour of the table.

```ruby
  filter: true,          # false for no filter row at all
  search: true,          # show fuzzy search field
  paginate: false,       # true to show paginator
  pagesize: 20,          # default pagesize
  sortable: true,        # true to allow sorting (can be specified for every sortable column)
  batch_actions: false,  # :name => value hash of batch action stuff
  footer_content: false, # if given, add a <%= content_for <footer_content> %> before the </table>
  path: '#',             # where to send the AJAX-requests to
  order_by: nil          # default order
```

#### Example:
```erb
<%= table_for Product, {order_by: 'price desc', pagesize: 50} %>
```

### Column Options

You can specify these options either in your `TabulatrData` class or to
the columns in the block of `table_for`.

```ruby
  header: nil,           # override content of header cell
  classes: nil,          # CSS classes for this column
  width: false,
  align: false,
  valign: false,
  wrap: nil,
  th_html: false,
  filter_html: false,
  filter: true,          # whether this column should be filterable
  sortable: true,        # whethter this column should be sortable
  format: nil,
  map: true,
  cell_style: {},        # CSS style for all body cells of this column
  header_style: {}       # CSS style for all header cells of this column
```

#### Example:
```erb
# in the view
<%= table_for Product do |t|
  t.column(:title, header_style: {color: 'red'})
  # ...
%>

# or in TabulatrData
class ProductTabulatrData < Tabulatr::Data
  column(:title, table_column_options: {header_style: {color: 'red'}})
end
```

## Dependencies

We use [Bootstrap from Twitter](http://getbootstrap.com) in order to make the table look pretty decent.

## Known Bugs

### Request-URI Too Large error

This is a problem particulary when using WEBrick, because WEBricks URIs must not exceed 2048 characters.
And this limit is hard-coded IIRC. So – If you run into this limitation –
please consider using another server.
(Thanks to [stepheneb](https://github.com/stepheneb) for calling my attention back to this.)

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
