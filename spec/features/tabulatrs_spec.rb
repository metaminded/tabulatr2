require 'rails_helper'

feature "Tabulatr" do

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

  feature "General data" do

    scenario "contains buttons" do
      visit simple_index_products_path
      ['.tabulatr-filter-menu-wrapper', '.tabulatr-batch-actions-menu-wrapper',
        '.tabulatr-paginator-wrapper'].each do |n|
        expect(find(n).visible?)
      end
    end

    scenario "contains column headers" do
      visit simple_index_products_path
      ['Title','Price','Active','Updated at'].each do |n|
        expect(page).to have_css('.tabulatr_table thead', text: n)
      end
    end

    scenario "contains the actual data", js: true do
      product = Product.create!(:title => names[0], :active => true, :price => 10.0)
      product.vendor = @vendor1
      product.save!
      visit simple_index_products_path
      expect(page).to have_content("true")
      expect(page).to have_content("10.0")
      expect(product.vendor.name).to eq("ven d'or")
      expect(page).to have_css('.tabulatr_table tbody', text: names[0])
      expect(page).to have_css('.tabulatr_table tbody', text: "ven d'or")
    end

    scenario "correctly contains the association data", js: true do
      product = Product.create!(:title => names[0], :active => true, :price => 10.0)
      [@tag1, @tag2, @tag3].each_with_index do |tag, i|
        product.tags << tag
        product.save
        visit simple_index_products_path
        expect(page).to have_content(tag.title.upcase)
      end
    end

    scenario "contains the actual data multiple times", js: true do
      9.times do |i|
        product = Product.create!(:title => names[i], :active => i.even?, :price => 11.0+i,
          :vendor => i.even? ? @vendor1 : @vendor2)
        visit simple_index_products_path
        expect(page).to have_content(names[i])
        expect(page).to have_content((11.0+i).to_s)
      end
    end

    scenario "contains the further data on the further pages" do
      names[10..-1].each_with_index do |n,i|
        product = Product.create!(:title => n, :active => i.even?, :price => 20.0+i,
          :vendor => i.even? ? @vendor1 : @vendor2)
        visit simple_index_products_path
        expect(page).to have_no_content(/\s+#{n}\s+/)
        expect(page).to have_no_content((30.0+i).to_s)
      end
    end
  end

  feature 'has_many' do
    scenario 'displays the count when called with :count', js: true do
      product = Product.create!(:title => names[0], :active => true, :price => 10.0)
      [@tag1, @tag2, @tag3].each do |tag|
        product.tags << tag
      end
      product.save
      visit count_tags_products_path
      expect(page).to have_css('tbody td[data-tabulatr-column-name="tags:count"]', text: '3')
    end
  end

  feature "Pagination" do


    context 'pagination setting is true' do
      scenario 'has pages', js: true do
        5.times do |i|
          Product.create!(:title => "test #{i}")
        end
        visit one_item_per_page_with_pagination_products_path
        expect(page).to have_css('.pagination li a[data-page]', count: 5)
      end

      scenario 'shows some pages when there are 20', js: true do
        20.times do |i|
          Product.create!
        end
        visit one_item_per_page_with_pagination_products_path
        pages = page.all('.pagination li a[data-page]').map{|a| a['data-page'].to_i}
        expect(pages).to match_array([1,2,3,10,20])
      end
    end
    context 'pagination setting is false' do
      scenario 'has no pages', js: true do
        5.times do |i|
          Product.create!
        end
        visit one_item_per_page_without_pagination_products_path
        expect(page).to have_no_css('.pagination li a')
      end
    end
  end

  feature "Filters" do
    scenario "filters with like", js: true do
      names.each do |n|
        Product.create!(:title => n, :active => true, :price => 10.0)
      end
      visit simple_index_products_path
      click_link 'Filter'
      fill_in("product_filter[products:title][like]", with: "ore")
      expect(page).to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'lorem')
      expect(page).to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'labore')
      expect(page).to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'dolore')

      within(".tabulatr_filter_form") do
        fill_in("product_filter[products:title][like]", :with => "loreem")
      end
      expect(page).not_to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'lorem')
      expect(page).not_to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'labore')
      expect(page).not_to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'dolore')
    end

    scenario "filters", js: true do
      Product.create!([{title: 'foo', vendor: @vendor1},
                       {title: 'bar', vendor: @vendor2}])
      visit simple_index_products_path
      click_link 'Filter'
      find('form.tabulatr_filter_form').fill_in("product_filter[vendor:name]", with: "producer")
      expect(page).not_to have_selector('td[data-tabulatr-column-name="vendor:name"]', text: @vendor1.name)
      expect(page).to have_selector('td[data-tabulatr-column-name="vendor:name"]', text: @vendor2.name)
    end

    scenario "without filters", js: true do
      visit without_filters_products_path
      expect(page).to have_no_content('Filter')
    end

    scenario "filters with range", js: true do
      n = names.length
      Product.create!([{title: 'foo', price: 5}, {title: 'bar', price: 17}])
      visit simple_index_products_path

      click_link 'Filter'
      within('.tabulatr_filter_form') do
        fill_in("product_filter[products:price][from]", :with => 4)
        wait_for_ajax
        fill_in("product_filter[products:price][to]", :with => 10)
        wait_for_ajax
      end
      expect(page).to have_no_css('.tabulatr-spinner-box')
      expect(page).to have_css(".tabulatr_table tbody tr", text: 'foo')
      expect(page).to have_no_css(".tabulatr_table tbody tr", text: 'bar')
      within('.tabulatr_filter_form') do
        fill_in("product_filter[products:price][from]", :with => 12)
        wait_for_ajax
        fill_in("product_filter[products:price][to]", :with => 19)
        wait_for_ajax
      end
      expect(page).to have_no_css('.tabulatr-spinner-box')
      expect(page).to have_css(".tabulatr_table tbody tr", text: 'bar')
      expect(page).to have_no_css(".tabulatr_table tbody tr", text: 'foo')
    end

    scenario "filters enums", js: true do
      skip unless Product.respond_to?(:enum)
      Product.create!([{title: 'foo', price: 5, status: 'in_stock'},
                       {title: 'bar', price: 10, status: 'out_of_stock'}])
      visit simple_index_products_path
      expect(page).to have_css('.tabulatr_table tbody', text: 'foo')
      expect(page).to have_css('.tabulatr_table tbody', text: 'bar')
      click_link 'Filter'
      within('.tabulatr_filter_form') do
        select 'in_stock', from: 'product_filter[products:status]'
      end
      expect(page).to have_no_css('.tabulatr-spinner-box')
      expect(page).to have_css('.tabulatr_table tbody', text: 'foo')
      expect(page).to have_no_css('.tabulatr_table tbody', text: 'bar')
      within('.tabulatr_filter_form') do
        select 'out_of_stock', from: 'product_filter[products:status]'
      end
      expect(page).to have_no_css('.tabulatr-spinner-box')
      expect(page).to have_css('.tabulatr_table tbody', text: 'bar')
      expect(page).to have_no_css('.tabulatr_table tbody', text: 'foo')

    end

    scenario 'removes the filters', js: true do
      Product.create!([{title: 'foo', price: 5}, {title: 'bar', price: 5}])
      visit simple_index_products_path
      click_link 'Filter'
      within(".tabulatr_filter_form") do
        fill_in("product_filter[products:title][like]", with: "foo")
      end
      expect(page).not_to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'bar')
      expect(page).to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'foo')
      find('.tabulatr-reset-table').click
      expect(page).to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'bar')
      expect(page).to have_selector('td[data-tabulatr-column-name="products:title"]', text: 'foo')
    end

    scenario 'custom filters', js: true do
      Product.create!([{title: 'foo', price: 7.5, vendor: @vendor1}, {title: 'bar', price: 90, vendor: @vendor1}])
      Product.create!([{title: 'baz', price: 125, vendor: @vendor2}, {title: 'fubar', price: 133.3, vendor: @vendor2}, {title: 'fiz', price: 97, vendor: @vendor2}])
      visit vendors_path
      expect(page).to have_css(".tabulatr_table tbody tr", count: 2)
      click_link 'Filter'
      within(".tabulatr_filter_form") do
        select("Expensive", from: "vendor_filter[product_price_range]")
      end
      expect(page).to have_css(".tabulatr_table tbody tr", count: 1)
      expect(page).to have_css('.tabulatr_table tbody td', text: @vendor2.name)
      within(".tabulatr_filter_form") do
        select("Cheap", from: "vendor_filter[product_price_range]")
      end
      expect(page).to have_css(".tabulatr_table tbody tr", count: 1)
      expect(page).to have_css('.tabulatr_table tbody td', text: @vendor1.name)
    end

    scenario 'custom split filters', js: true do
      Product.create!([{title: 'foo', price: 7.5, vendor: @vendor1}, {title: 'bar', price: 90, vendor: @vendor1}])
      Product.create!([{title: 'baz', price: 125, vendor: @vendor2}, {title: 'fubar', price: 133.3, vendor: @vendor2}, {title: 'fiz', price: 97, vendor: @vendor2}])
      visit vendors_path + '?split=5'
      expect(page).to have_css(".tabulatr_table tbody tr", count: 2)
      click_link 'Filter'
      within(".tabulatr_filter_form") do
        select("Expensive", from: "vendor_filter[product_price_range]")
      end
      expect(page).to have_css(".tabulatr_table tbody tr", count: 2)
      expect(page).to have_css('.tabulatr_table tbody td', text: @vendor1.name)
      expect(page).to have_css('.tabulatr_table tbody td', text: @vendor2.name)
      within(".tabulatr_filter_form") do
        select("Cheap", from: "vendor_filter[product_price_range]")
      end
#      wait_for_ajax
      expect(page).to have_css(".tabulatr_table tbody tr", count: 0, wait: 10)
    end
  end

  feature "Sorting" do
    scenario "knows how to sort", js: true do
      names.each do |n|
        Product.create!(title: n, vendor: @vendor1, active: true, price: 10.0)
      end
      visit simple_index_products_path
      l = names.count
      (1..10).each do |i|
        expect(page).to have_content names[l-i]
      end
      within('.tabulatr_table thead') do
        find('th[data-tabulatr-column-name="products:title"]').click
      end
      snames = names.sort
      (1..10).each do |i|
        expect(page).to have_content snames[i-1]
      end
      within('.tabulatr_table thead') do
        find('th[data-tabulatr-column-name="products:title"]').click
      end
      (1..10).each do |i|
        expect(page).to have_content snames[-i]
      end
    end
  end

  feature "Show simple records" do

    scenario "contains the actual data", js: false do
      names.shuffle.each.with_index do |n,i|
        p = Product.new(:title => n, :active => true, :price => 10.0 + i)
        p.vendor = [@vendor1, @vendor2].shuffle.first
        p.tags = [@tag1, @tag2, @tag3].shuffle[0..rand(3)]
        p.save!
      end
      visit stupid_array_products_path
      Product.order('price asc').limit(11).each do |product|
        expect(page).to have_content(product.title)
        expect(page).to have_content(product.title.upcase)
        expect(page).to have_content(product.price)
        expect(page).to have_content(product.vendor.name)
        expect(page).to have_content(product.title)
        expect(page).to have_content("foo#{product.title}foo")
        expect(page).to have_content("bar#{product.title}bar")
        expect(page).to have_content("%08.4f" % product.price)
        expect(page).to have_content(product.tags.count)
        product.tags.each do |tag|
          expect(page).to have_content(tag.title)
          expect(page).to have_content("foo#{tag.title}foo")
          expect(page).to have_content("bar#{tag.title}bar")
        end
      end
    end
  end

  feature "Batch actions", js: true do

    scenario "hides the actions if there are none" do
      visit one_item_per_page_with_pagination_products_path
      expect(page).to have_no_selector('.tabulatr-batch-actions-menu-wrapper a')
    end


    scenario 'executes the action when clicked' do
      product1 = Product.create!(:title => names[0], :active => true, :price => 10.0)
      product2 = Product.create!(:title => names[1], :active => true, :price => 10.0)
      product3 = Product.create!(:title => names[2], :active => true, :price => 10.0)
      visit with_batch_actions_products_path
      expect(page).to have_css(".tabulatr_table tbody tr", count: 3)
      find(".tabulatr-checkbox[value='#{product1.id}']").trigger('click')
      find(".tabulatr-checkbox[value='#{product3.id}']").trigger('click')
      find('.tabulatr-batch-actions-menu-wrapper a').click
      within('.dropdown.open') do
        click_link 'Delete'
      end
      expect(page).to have_css(".tabulatr_table tbody tr", count: 1)
    end

    scenario 'executes the action for all items if nothing selected' do
      product1 = Product.create!(:title => names[0], :active => true, :price => 10.0)
      product2 = Product.create!(:title => names[1], :active => true, :price => 10.0)
      product3 = Product.create!(:title => names[2], :active => false, :price => 10.0)
      visit with_batch_actions_products_path
      find('.tabulatr-batch-actions-menu-wrapper a').click
      within('.dropdown.open') do
        click_link 'Delete'
      end
      expect(page).to have_css('.tabulatr_table tbody tr', count: 0)
    end
  end

  feature "Column options", js: true do
    scenario 'applys the given style' do
      p = Product.create!(:title => names[0], :active => true, :price => 10.0)
      visit with_styling_products_path
      cell   = find(".tabulatr_table tbody td[data-tabulatr-column-name='products:title']")
      header = find(".tabulatr_table thead th[data-tabulatr-column-name='products:title']")
      cell_without_style   = find(".tabulatr_table tbody td[data-tabulatr-column-name='products:price']")
      header_without_style = find(".tabulatr_table thead th[data-tabulatr-column-name='products:price']")
      expect(cell[:style]).to eql 'background-color: green;text-align: left;width: 60px;white-space: nowrap;'
      expect(header[:style]).to eql 'color: orange;text-align: left;width: 60px;white-space: nowrap;'
      expect(cell_without_style[:style]).to be_empty
      expect(header_without_style[:style]).to be_empty
    end
  end
end
