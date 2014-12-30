class Product < ActiveRecord::Base
  if self.respond_to?(:enum)
    enum status: [:in_stock, :short, :out_of_stock]
  end

  belongs_to :vendor
  has_and_belongs_to_many :tags
end
