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
