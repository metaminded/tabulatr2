## UNRELEASED
  * Add `filter` to DSL to define custom filters

    Example:
    ```
    filter :product_price_range do |relation, value|
      relation = relation.joins(:products)
      if value == 'low'
        relation.group("vendors.id").having('AVG(products.price) <= 100')
      elsif value == 'high'
        relation.group("vendors.id").having('AVG(products.price) > 100')
      end
    end
    ```
 * Add `current_user` local to Tabulatr::Data by default if available
   and not already present

## 0.9.17
 * If a batch action is executed without checking any rows it
   will be applied to all rows in the current filter

 * Add filter `enum_multiselect`

   Example:
   ```
   column :status, filter: :enum_multiselect
   ```

## 0.9.16
   Adds `paginate` as config option

## 0.9.15
 * Adds filter support for `enum`
   If it detects an enum it creates a dropdown filter with the possible enum
   values as options.

   fixes #35

 * Removes bootstrap2 CSS modifications

## 0.9.6
 * Adds localStorage persistency for tables. It's automatically turned on for paginated
   tables and you can adjust the setting in your template.

   Example:
   ```
   table_for Product, persistent: false
   ```

 * Added `font-awesome-rails`

 * The DSL now accepts a search block with two block variables. The
   second being the relation. The block needs to return an ActiveRecord::Relation,
   a Hash, a String, nil or an Array.

   Example:
   ```ruby
   search do |query, relation|
    relation.joins(:vendor).where(["vendors.name = ?", query])
   end
   ```

## 0.9.5
 * Better DOM scopes to enable working with multiple tables per page
 * Added `pagination_position` option to `table_for`.
   Possible values are `:top`, `:bottom` and `:both`.
 * Add 'mark all' checkbox in header row again
 * Added `html_class` option to `table_for`

## 0.9.4

 * Fixed date filters

 * Added missing translations to the install generator.

## 0.9.3

 * Tabulatr is now stopped from retrieving data in endless pagination mode when all data
   is already on the client.

 * Automatically determine appropriate filter types for the columns

 * Boolean filter is now a `select` field with `yes`, `no`, `both` options

 * User can pass in additional variables to the TabulatrData-Class via the
   `locals` argument.

  Example:
  ```
  tabulatr_for Product, locals: {current_user: current_user}
  ```

## 0.9.2

* Fixed bug which caused a reload of the website when clicking on the current
  table page again.

## 0.9.1

* Show spinner when data is loading. Type of spinner can be overriden via
  `Tabulatr.spinner` option. Possible values are :standard and :pacman.

  Example:
  ```
    Tabulatr.config do |tc|
      tc.spinner = :pacman
    end
  ```

* does not complain when no id is manually provided in TabulatrData

## 0.9

* Added `row` to the TabulatrData DSL to provide HTML attributes for the
  table_row of each record.

  Example:
  ```
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

* Added `id` of record as `data-id` of table row in static table if
  id is available.

* Added `columns` keyword argument to `table_for`

* Added `checkbox` to the TabulatrData DSL

## 0.8.9

* fix sorting, filtering, searching and batch_actions for tables whose class
  is camelCased.

## 0.8.8

* new Generator:
  `tabulatr:install` - now only for creating I18n file
  `tabulatr:table MODEL` - for creating MODELTabulatrData class

* get rid of `bootstrap_paginator` option and initializer

* get rid of `security_tokens`

## 0.8.7

* fixed bug in association call

* support namespaced rails models

## 0.8.5

* Added `order_by` option to `table_for` for default sorting.

## 0.8.3

* New table_column_options `cell_style` and `header_style`
  Example:
  ```
  column :name, cell_style: {:'background-color' => 'red'}, header_style: {:'font-weight' => 'bold'}
  ```

* Added `classes` attribute to `table_column_options`.
  Example:
  ```
  column :foobar, table_column_options: {classes: "mycssclass foobar-column"}
  ```

* Fixed prefiltering.
  Example:
  ```
  tabulatr_for(Product.where(price: 10))
  ```
