# Tabulatr2 - Index Tables made easy
[![Gem Version](https://badge.fury.io/rb/tabulatr2.png)](http://badge.fury.io/rb/tabulatr2)
[![Code Climate](https://codeclimate.com/github/metaminded/tabulatr2.png)](https://codeclimate.com/github/metaminded/tabulatr2)
[![Travis CI](https://api.travis-ci.org/metaminded/tabulatr2.png)](https://travis-ci.org/metaminded/tabulatr2)

## Requirements

* Ruby 2.0.0 or higher
* Rails 4.0.0 or higher
* [Bootstrap from Twitter](http://getbootstrap.com)

## Installation

Require tabulatr2 in your Gemfile:
```ruby
gem 'tabulatr2'
```
After that run `bundle install`.

Also add `//= require tabulatr` to your application js file and `*= require tabulatr` to your CSS asset
pipeline. Make sure to add it after including the `bootstrap` assets.

In order to get the provided `i18n` language files run
`rails g tabulatr:install`

## Example

![example](https://cloud.githubusercontent.com/assets/570608/5580201/661c63c0-9047-11e4-9993-f71a0f1f4c00.png)

## The DSL

`Tabulatr` provides an easy to use DSL to define the data to be used in your table. It is defined in `TabulatrData`
classes. If you have a `User` model you would create a `UserTabulatrData` class.

```ruby
class UserTabulatrData < Tabulatr::Data
end
```

Instead of creating this class by hand you can also generate a `TabulatrData` for a given class by running
`rails g tabulatr:table User`

### Columns

Let's say you want to display each user's `first_name` and `last_name` attribute:

```ruby
class UserTabulatrData < Tabulatr::Data
  column :first_name
  column :last_name
end
```
That's it. It'll work, but let's assume you would like to display the full name in one single column. No worries! `Tabulatr` got you covered:

```ruby
class UserTabulatrData < Tabulatr::Data
  column :full_name, table_column_options: {header: 'The full name'} do |user|
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```
As you can see you just need to provide a block to the `column` call and you can format the cell into whatever you want.
You can even use all those fancy Rails helpers!

Unfortunately, we can't sort and filter this column right now because `Tabulatr` would look for a `full_name` column in
your DB table but there is no such thing. Bummer! Enter `sort_sql` and `filter_sql`:

#### Sorting / Filtering

```ruby
class UserTabulatrData < Tabulatr::Data
  column :full_name, sort_sql: "users.first_name || '' || users.last_name",
                   filter_sql: "users.first_name || '' || users.last_name"
end
```

With these two options you can provide whatever SQL you would like to have executed when filtering or sorting
this particular column. If instead you want to disable sorting and filtering at all, you can do that too:

```ruby
class UserTabulatrData < Tabulatr::Data
  column :full_name, table_column_options: {sortable: false, filter: false}
end
```

Also you are able to change generated filter form field for this column. Say for example you want to have an `exact`
filter instead of a `LIKE` filter:

```ruby
class UserTabulatrData < Tabulatr::Data
  column :first_name, table_column_options: {filter: :exact}
end
```

Following is a table with all the standard mappings for filter fields, which means these filters get created if you
don't overwrite it:

Data type | Generated form field / SQL
--------- | -------------------------
integer, float, decimal | String input field, exact match
string, text            | String input field, LIKE match
date, time, datetime, timestamp | Select field, with options like 'last 30 days', 'today', ...
boolean                         | Select field, options are 'Yes', 'No' and 'Both'


### Associations

To display associations you would use the `association` method with the association name and the attribute on the
association as it's first two arguments:

```ruby
class UserTabulatrData < Tabulatr::Data
  association :citizenship, :name
end
```

Associations take the same arguments as the `column` method:

```ruby
class UserTabulatrData < Tabulatr::Data
  association :citizenship, :name do
    record.citizenship.name.upcase
  end

  association :posts, :text, table_column_options: {filter: false, sortable: false} do |user|
    user.posts.count
  end
end
```

### Checkbox

To provide a checkbox for each row which is needed by batch actions just call `checkbox`:

```ruby
class UserTabulatrData < Tabulatr::Data
 checkbox
end
```

### Actions

To provide a column that's not sortable and filterable but renders something nice:

```ruby
class UserTabulatrData < Tabulatr::Data
  action do |r|
    link_to "edit", edit_product_path(r)
  end
end
```

### Buttons

To render a fancy button group:

```ruby
class UserTabulatrData < Tabulatr::Data
  buttons do |b,r|
    b.button :eye, product_path(r), class: 'btn-success'
    b.button :pencil, edit_product_path(r), class: 'btn-warning'
    b.submenu do |s|
      s.button :star, star_product_path(r), label: 'Dolle Sache'
      s.divider
      s.button :'trash-o', product_path(r), label: 'Löschen', confirmation: 'echt?', class: 'btn-danger', method: :delete
    end
  end
end
```

### Search

The DSL provides you with a `search` method to define a custom fuzzy search method which is not bound
to a specific column.

```ruby
class UserTabulatrData < Tabulatr::Data
  search do |query|
   "users.first_name LIKE '#{query}' OR users.last_name LIKE '#{query}' OR users.address LIKE '#{query}'"
  end

  # This call could also be written as:
  # search :first_name, :last_name, :address
end
```

### Custom filters

You're also able to create custom filters with the `filter` method to create more advanced
filters which are independent of the displayed columns.

```ruby
class UserTabulatrData < Tabulatr::Data
  filter :age_range do |relation, value|
    if value == 'upto_18'
      relation.where("birthday > ?", Date.today-18.years)
    elsif value == 'over_18'
      relation.where("birthday <= ?", Date.today-18.years)
    end
  end
end
```

This code will look for a partial to render in `tabulatr/filter/_age_range.*`.
You can override this path by specifying the `partial` argument of the `filter` method.
It will call it's block with the ActiveRecord::Relation and the submitted value after
the user submits the filter form.

```erb
# tabulatr/filter/_age_range.html.erb

<div class='form-group'>
  <label class='control-label' for="<%= input_id %>">Age range</label>
  <select id="<%= input_id %>" name="<%= input_name %>">
    <option value=''>None</option>
    <option value='upto_18'>0 - 17</option>
    <option value='over_18'>18+</option>
  </select>
</div>
```

As you can see there are two locales defined which should be used for your custom form
field: `input_name` and `input_id`

### Row formatting

To provide row specific HTML-Attributes call `row`:

```ruby
row do |record, row_config|
  if record.super_important?
    row_config[:class] = 'important';
  end
  row_config[:data] = {
    href: edit_user_path(record.id),
    vip: record.super_important?
  }
end
```

## Usage

Great, we have defined all the required `columns` in the TabulatrData DSL, but how do we display the table now?

In `UsersController#index` we write:

```ruby
  def index
    tabulatr_for User
  end
```
This call responds to an HTML-Request by rendering the associated `view` and for a JSON-Request by
fetching the requested records.


_Hint:_ If you want to prefilter your table, you can do that too! Just pass an `ActiveRecord::Relation` to `tabulatr_for`:
```ruby
  def index
    tabulatr_for User.where(active: true)
  end
```

In the view we can use all the attributes which are defined in our `UserTabulatrData` class.
To display all the columns defined in the `UserTabulatrData` class we
just need to put the following statement in our view:

```erb
<%= table_for User %>
```
If you just want do display a subset of the defined columns or show them in a
different order you can provide them as arguments to the `columns` key:

```erb
<%= table_for User, columns: [:full_name, 'citizenship:name', {posts: :text}]%>
```
Note that you can write associations as a string with colon between association
name and method or as a hash as you can see above.

An other option is to provide the columns in a block:

```erb
  <%= table_for User do |t|
    t.column :full_name
    t.column :active
    t.association :citizenship, :name
    t.association :posts, :text
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
  <%= table_for User, batch_actions: {'foo' => 'Foo', 'delete' => "Delete"} do |t|
    ...
  end %>
```

To handle the actual batch action, we have to add a block to the `tabulatr_for` call in the controller:

```ruby
  tabulatr_for User do |batch_actions|
    batch_actions.delete do |ids|
      ids.each do |id|
        User.find(id).destroy
      end
      redirect_to root_path()
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
  order_by: nil          # default order,
  html_class: ''         # html classes for the table element
  counter_position: :top # position of the counter row, can by :top, :bottom or :both
```

#### Example:
```erb
<%= table_for User, {order_by: 'last_name desc', pagesize: 50} %>
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
  filter_label: nil,
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
<%= table_for User do |t|
  t.column(:first_name, header_style: {color: 'red'})
  # ...
%>

# or in TabulatrData
class UserTabulatrData < Tabulatr::Data
  column(:first_name, table_column_options: {header_style: {color: 'red'}})
end
```

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

## License

[MIT](LICENSE)
