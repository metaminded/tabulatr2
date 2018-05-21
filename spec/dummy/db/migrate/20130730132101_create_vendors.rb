class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :url
      t.boolean :active
      t.text :description

      t.timestamps null: false
    end
  end
end
