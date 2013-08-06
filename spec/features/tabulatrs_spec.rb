require 'spec_helper'

describe "Tabulatrs" do
  # before { pending }

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
  ids = []

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

    # it "contains other elements" do
    #   visit simple_index_products_path
    #   page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 0, 0, 0, 0))
    # end

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

    # it "contains row identifiers" do
    #   visit simple_index_products_path
    #   Product.all.each do |product|
    #     page.should have_css("#product_#{product.id}")
    #   end
    # end

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

  describe "Pagination" do


    context 'pagination setting is true' do
      it 'has pages', js: true do
        5.times do |i|
          Product.create!(:title => "test #{i}")
        end
        visit one_item_per_page_with_pagination_products_path
        page.all('.pagination ul a').count.should eq 5
      end

      it 'shows some pages when there are 20', js: true do
        20.times do |i|
          Product.create!
        end
        visit one_item_per_page_with_pagination_products_path
        pages = page.all('.pagination ul a').map{|a| a['data-page'].to_i}
        pages.should eq [1,2,3,10,20]
      end
    end
    context 'pagination setting is false' do
      it 'has no pages', js: true do
        5.times do |i|
          Product.create!
        end
        visit one_item_per_page_without_pagination_products_path
        page.all('.pagination ul a').count.should be 0
      end
    end
  end

  describe "Filters", pending: true do
    it "filters" do
      visit simple_index_products_path
      fill_in("product_filter[title]", :with => "lorem")
      click_button("Apply")
      page.should have_content("lorem")
      page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 1, names.length, 0, 1))
      fill_in("product_filter[title]", :with => "loreem")
      click_button("Apply")
      page.should_not have_content("lorem")
      page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 0, names.length, 0, 0))
    end

    it "filters with like" do
      visit index_filters_products_path
      %w{a o lo lorem}.each do |str|
        fill_in("product_filter[title][like]", :with => str)
        click_button("Apply")
        page.should have_content(str)
        tot = (names.select do |s| s.match Regexp.new(str) end).length
        page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, names.length, 0, tot))
      end
    end

    it "filters with range" do
      visit index_filters_products_path
      n = names.length
      (0..n/2).each do |i|
        fill_in("product_filter[price][from]", :with => (10+i).to_s)
        fill_in("product_filter[price][to]", :with => "")
        click_button("Apply")
        tot = n-i
        page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, n, 0, tot))
        fill_in("product_filter[price][to]", :with => (10+i).to_s)
        fill_in("product_filter[price][from]", :with => "")
        click_button("Apply")
        tot = i+1
        page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, n, 0, tot))
        fill_in("product_filter[price][from]", :with => (10+i).to_s)
        fill_in("product_filter[price][to]", :with => (10+n-i-1).to_s)
        click_button("Apply")
        tot = n-i*2
        page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, n, 0, tot))
      end
    end
  end

  describe "Sorting", pending: true do
    it "knows how to sort" do
      visit index_sort_products_path
      (1..10).each do |i|
        page.should have_content names[-i]
      end
      click_button("product_sort_title_desc")
      snames = names.sort
      (1..10).each do |i|
        page.should have_content snames[-i]
      end
      click_button("product_sort_title_asc")
      (1..10).each do |i|
        page.should have_content snames[i-1]
      end
    end
  end

end





