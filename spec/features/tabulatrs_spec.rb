require 'spec_helper'

describe "Tabulatr" do

  names = ["lorem", "ipsum", "dolor", "sit", "amet", "consectetur",
  "adipisicing", "elit", "sed", "eiusmod", "tempor", "incididunt", "labore",
  "dolore", "magna", "aliqua", "enim", "minim", "veniam,", "quis", "nostrud",
  "exercitation", "ullamco", "laboris", "nisi", "aliquip", "commodo",
  "consequat", "duis", "aute", "irure", "reprehenderit", "voluptate", "velit",
  "esse", "cillum", "fugiat", "nulla", "pariatur", "excepteur", "sint",
  "occaecat", "cupidatat", "non", "proident", "sunt", "culpa", "qui",
  "officia", "deserunt", "mollit", "anim", "est", "laborum"]

  before(:each) do
    @vendor1 = Vendor.create!(:name => "ven d'or", :active => true)
    @vendor2 = Vendor.create!(:name => 'producer', :active => true)
    @tag1 = Tag.create!(:title => 'foo')
    @tag2 = Tag.create!(:title => 'bar')
    @tag3 = Tag.create!(:title => 'fubar')
  end

  describe "General data" do

    it "contains buttons" do
      visit simple_index_products_path
      ['Filter'].each do |n|
        page.should have_content(n)
      end
    end

    it "contains column headers" do
      visit simple_index_products_path
      ['Title','Price','Active','Updated At'].each do |n|
        find('.tabulatr_table thead').should have_content(n)
      end
    end

    it "contains the actual data", js: true do
      product = Product.create!(:title => names[0], :active => true, :price => 10.0)
      product.vendor = @vendor1
      product.save!
      visit simple_index_products_path
      page.should have_content("true")
      page.should have_content("10.0")
      product.vendor.name.should eq("ven d'or")
      find('.tabulatr_table tbody').should have_content(names[0])
      find('.tabulatr_table tbody').should have_content("ven d'or")
    end

    it "correctly contains the association data", js: true do
      product = Product.create!(:title => names[0], :active => true, :price => 10.0)
      [@tag1, @tag2, @tag3].each_with_index do |tag, i|
        product.tags << tag
        product.save
        visit simple_index_products_path
        page.should have_content tag.title
      end
    end

    it "contains the actual data multiple", js: true do
      9.times do |i|
        product = Product.create!(:title => names[i], :active => i.even?, :price => 11.0+i,
          :vendor => i.even? ? @vendor1 : @vendor2)
        visit simple_index_products_path
        page.should have_content(names[i])
        page.should have_content((11.0+i).to_s)
      end
    end

    it "contains the further data on the further pages" do
      names[10..-1].each_with_index do |n,i|
        product = Product.create!(:title => n, :active => i.even?, :price => 20.0+i,
          :vendor => i.even? ? @vendor1 : @vendor2)
        visit simple_index_products_path
        page.should_not have_content(n)
        page.should_not have_content((30.0+i).to_s)
      end
    end
  end

  describe 'has_many' do
    it 'displays the count when called with :count', js: true do
      product = Product.create!(:title => names[0], :active => true, :price => 10.0)
      [@tag1, @tag2, @tag3].each do |tag|
        product.tags << tag
      end
      product.save
      visit count_tags_products_path
      page.should have_content 3
    end
  end

  describe "Pagination" do


    context 'pagination setting is true' do
      it 'has pages', js: true do
        5.times do |i|
          Product.create!(:title => "test #{i}")
        end
        visit one_item_per_page_with_pagination_products_path
        page.all('.pagination li a').count.should eq 5
      end

      it 'shows some pages when there are 20', js: true do
        20.times do |i|
          Product.create!
        end
        visit one_item_per_page_with_pagination_products_path
        pages = page.all('.pagination li a').map{|a| a['data-page'].to_i}
        pages.should eq [1,2,3,10,20]
      end
    end
    context 'pagination setting is false' do
      it 'has no pages', js: true do
        5.times do |i|
          Product.create!
        end
        visit one_item_per_page_without_pagination_products_path
        page.all('.pagination li a').count.should be 0
      end
    end
  end

  describe "Filters", js: true do
    it "filters with like" do
      names.each do |n|
        Product.create!(:title => n, :active => true, :price => 10.0)
      end
      visit simple_index_products_path
      find('.icon-filter').trigger('click')
      fill_in("product_filter[title][like]", :with => "ore")
      click_button("Apply")
      page.should have_content("lorem")
      page.should have_content("labore")
      page.should have_content("dolore")
      find('.icon-filter').trigger('click')
      fill_in("product_filter[title][like]", :with => "loreem")
      click_button("Apply")
      page.should_not have_content("lorem")
    end

    it "filters" do
      Product.create!([{title: 'foo', vendor: @vendor1},
                       {title: 'bar', vendor: @vendor2}])
      visit simple_index_products_path
      find('.icon-filter').trigger('click')
      fill_in("product_filter[__association][vendor.name]", :with => 'producer')
      click_button("Apply")
      page.should have_content(@vendor2.name)
      page.should_not have_content(@vendor1.name)
    end

    it "filters with range" do
      visit simple_index_products_path
      n = names.length
      Product.create!([{title: 'foo', price: 5}, {title: 'bar', price: 17}])
      find('.icon-filter').trigger('click')
      fill_in("product_filter[price][from]", :with => 4)
      fill_in("product_filter[price][to]", :with => 10)
      click_button("Apply")
      page.should have_content('foo')
      page.should_not have_content('bar')
      find('.icon-filter').trigger('click')
      fill_in("product_filter[price][from]", :with => 12)
      fill_in("product_filter[price][to]", :with => 19)
      click_button("Apply")
      page.should have_content('bar')
      page.should_not have_content('foo')
    end
  end

  describe "Sorting" do
    it "knows how to sort", js: true do
      names.each do |n|
        Product.create!(title: n, vendor: @vendor1, active: true, price: 10.0)
      end
      Product.count.should > 10
      visit simple_index_products_path
      (1..10).each do |i|
        page.should have_content names[i-1]
      end
      find("#product_sort_title").trigger('click')
      snames = names.sort
      (1..10).each do |i|
        page.should have_content snames[-i]
      end
      find("#product_sort_title").trigger('click')
      (1..10).each do |i|
        page.should have_content snames[i-1]
      end
    end
  end

  describe 'multiple tables', js: true do
    it 'displays both tables' do
      visit multiple_tables_path
      page.should have_content('producer')
      page.should have_content('fubar')
    end
  end
end
