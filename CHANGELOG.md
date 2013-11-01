## 0.8.3

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
