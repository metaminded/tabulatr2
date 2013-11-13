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
      ['.tabulatr-filter-menu-wrapper', '.tabulatr-batch-actions-menu-wrapper',
        '.tabulatr-paginator-wrapper'].each do |n|
        expect(find(n).visible?)
      end
    end

    it "contains column headers" do
      visit simple_index_products_path
      ['Title','Price','Active','Updated at'].each do |n|
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
        page.should have_content tag.title.upcase
      end
    end

    it "contains the actual data multiple times", js: true do
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
        page.should_not have_content(/\s+#{n}\s+/)
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
      find(".tabulatr-filter-menu-wrapper a.btn").click
      within(".tabulatr-filter-menu-wrapper .dropdown.open") do
        find_link('Title').click
      end
      expect(find('.dropdown-menu').visible?)
      find(".tabulatr-filter-menu-wrapper a.btn").trigger('click')
      within(".tabulatr_filter_form") do
        fill_in("product_filter[title][like]", with: "ore")
        expect(find('#title_from').visible?)
        click_button("Apply")
      end
      page.should have_content("lorem")
      page.should have_content("labore")
      page.should have_content("dolore")
      within(".tabulatr_filter_form") do
        fill_in("product_filter[title][like]", :with => "loreem")
        click_button("Apply")
      end
      page.should_not have_content("lorem")
      page.should_not have_content("labore")
      page.should_not have_content("dolore")
    end

    it "filters" do
      Product.create!([{title: 'foo', vendor: @vendor1},
                       {title: 'bar', vendor: @vendor2}])
      visit simple_index_products_path
      find(".tabulatr-filter-menu-wrapper a.btn").click
      within(".tabulatr-filter-menu-wrapper .dropdown.open") do
        find_link('Vendor Name').click
      end
      find(".tabulatr-filter-menu-wrapper a.btn").trigger('click')
      within(".tabulatr_filter_form") do
        fill_in("product_filter[vendor:name]", with: "producer")
        click_button("Apply")
      end
      page.should have_content(@vendor2.name)
      page.should have_no_content(@vendor1.name)
    end

    it "filters with range", js: true do
      n = names.length
      Product.create!([{title: 'foo', price: 5}, {title: 'bar', price: 17}])
      visit simple_index_products_path
      find(".tabulatr-filter-menu-wrapper a.btn").click
      within(".tabulatr-filter-menu-wrapper .dropdown.open") do
        find_link('Price').click
      end
      find(".tabulatr-filter-menu-wrapper a.btn").trigger('click')
      within('.tabulatr_filter_form') do
        fill_in("product_filter[price][from]", :with => 4)
        fill_in("product_filter[price][to]", :with => 10)
        click_button("Apply")
      end
      page.find(".tabulatr_table tbody tr[data-id='#{Product.first.id}']").should have_content('foo')
      page.has_no_css?(".tabulatr_table tbody tr[data-id='#{Product.last.id}']")
      within('.tabulatr_filter_form') do
        fill_in("product_filter[price][from]", :with => 12)
        fill_in("product_filter[price][to]", :with => 19)
        click_button("Apply")
      end
      page.should have_selector(".tabulatr_table tbody tr[data-id='#{Product.last.id}']")
      page.should have_no_selector(".tabulatr_table tbody tr[data-id='#{Product.first.id}']")
    end

    it 'removes the filters', js: true do
      Product.create!([{title: 'foo', price: 5}, {title: 'bar', price: 5}])
      visit simple_index_products_path
      find(".tabulatr-filter-menu-wrapper a.btn").click
      within(".tabulatr-filter-menu-wrapper .dropdown.open") do
        find_link('Title').click
      end
      expect(find('.dropdown-menu').visible?)
      find(".tabulatr-filter-menu-wrapper a.btn").trigger('click')
      within(".tabulatr_filter_form") do
        fill_in("product_filter[title][like]", with: "foo")
        expect(find('#title_from').visible?)
        click_button("Apply")
      end
      expect(page).to have_content('foo')
      expect(page).to have_no_content('bar')
      find("a[data-hide-table-filter='title']").click
      expect(page).to have_content('foo')
      expect(page).to have_content('bar')
    end
  end

  describe "Sorting" do
    it "knows how to sort", js: true do
      names.each do |n|
        Product.create!(title: n, vendor: @vendor1, active: true, price: 10.0)
      end
      Product.count.should > 10
      visit simple_index_products_path
      l = names.count
      (1..10).each do |i|
        page.should have_content names[l-i]
      end
      within('.tabulatr_table thead') do
        find('th[data-tabulatr-column-name=title]').click
      end
      snames = names.sort
      (1..10).each do |i|
        page.should have_content snames[i-1]
      end
      within('.tabulatr_table thead') do
        find('th[data-tabulatr-column-name=title]').click
      end
      (1..10).each do |i|
        page.should have_content snames[-i]
      end
    end
  end

  describe "Show simple records" do

    it "contains the actual data", js: false do
      names.shuffle.each.with_index do |n,i|
        p = Product.new(:title => n, :active => true, :price => 10.0 + i)
        p.vendor = [@vendor1, @vendor2].shuffle.first
        p.tags = [@tag1, @tag2, @tag3].shuffle[0..rand(3)]
        p.save!
      end
      visit stupid_array_products_path
      Product.order('price asc').limit(11).each do |product|
        page.should have_content(product.title)
        page.should have_content(product.title.upcase)
        page.should have_content(product.price)
        page.should have_content(product.vendor.name)
        page.should have_content(product.title)
        page.should have_content("foo#{product.title}foo")
        page.should have_content("bar#{product.title}bar")
        page.should have_content("%08.4f" % product.price)
        page.should have_content(product.tags.count)
        product.tags.each do |tag|
          page.should have_content(tag.title)
          page.should have_content("foo#{tag.title}foo")
          page.should have_content("bar#{tag.title}bar")
        end
      end
    end
  end

  describe "Batch actions", js: true do

    it "hides the actions if there are none" do
      visit one_item_per_page_with_pagination_products_path
      page.should have_no_selector('.tabulatr-batch-actions-menu-wrapper a')
    end


    it 'executes the action when clicked' do
      product1 = Product.create!(:title => names[0], :active => true, :price => 10.0)
      product2 = Product.create!(:title => names[1], :active => true, :price => 10.0)
      product3 = Product.create!(:title => names[2], :active => true, :price => 10.0)
      page.has_css?(".tabulatr_table tbody tr", :count => 3)
      visit with_batch_actions_products_path
      find(".tabulatr-checkbox[value='#{product1.id}']").trigger('click')
      find(".tabulatr-checkbox[value='#{product3.id}']").trigger('click')
      find('.tabulatr-batch-actions-menu-wrapper a').click
      within('.dropdown.open') do
        click_link 'Delete'
      end
      page.has_css?(".tabulatr_table tbody tr", :count => 1)
    end
  end

  describe "Column options", js: true do
    it 'applys the given style' do
      p = Product.create!(:title => names[0], :active => true, :price => 10.0)
      visit with_styling_products_path
      cell   = find(".tabulatr_table tbody td[data-tabulatr-column-name='title']")
      header = find(".tabulatr_table thead th[data-tabulatr-column-name='title']")
      cell_without_style   = find(".tabulatr_table tbody td[data-tabulatr-column-name='price']")
      header_without_style = find(".tabulatr_table thead th[data-tabulatr-column-name='price']")
      expect(cell[:style]).to eql 'text-align:left;width:60px;vertical-align:top;white-space:nowrap;background-color:green'
      expect(header[:style]).to eql 'text-align:left;width:60px;vertical-align:top;white-space:nowrap;color:orange'
      expect(cell_without_style[:style]).to be_empty
      expect(header_without_style[:style]).to be_empty
    end
  end
end
