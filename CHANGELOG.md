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
