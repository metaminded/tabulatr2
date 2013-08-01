class Product < ActiveRecord::Base
  belongs_to :vendor
  has_and_belongs_to_many :tags
end
