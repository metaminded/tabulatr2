class Product < ActiveRecord::Base

  tabulatr_name_mapping full_title: %{("title" || ' ' || "price")}

  belongs_to :vendor
  has_and_belongs_to_many :tags
end
