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
