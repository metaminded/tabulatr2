class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :title

      t.timestamps null: false
    end

    create_table :products_tags, id: false do |t|
      t.references :tag
      t.references :product
    end
  end
end
