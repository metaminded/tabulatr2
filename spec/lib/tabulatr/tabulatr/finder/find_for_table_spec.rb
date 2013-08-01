require 'spec_helper'


class Example
end

describe Tabulatr::Finder do
  describe '#find_for_table' do
    before(:each) do
      Tabulatr::Security.stub(:validate!){ true }
    end

    context 'descends_from_activerecord' do
      it 'works fine' do
        expect{ subject.find_for_table(Product, {})}.to_not raise_error
      end
    end

    context 'doesn\'t descend_from_activerecord' do
      it 'raises an exception' do
        expect{ subject.find_for_table(Example, {})}.to raise_error
      end
    end

    it 'defines some methods' do
      result = subject.find_for_table(Product, {})
      result.should respond_to :__pagination
      result.should respond_to :to_tabulatr_json
      result.should respond_to :__sorting
      result.should respond_to :__filters
    end

    it 'orders the result' do
      p1 = Product.create!(title: 'abc')
      p2 = Product.create!(title: 'mno')
      result = subject.find_for_table(Product, {
        sort_by: :title,
        orientation: :asc,
        arguments: 'id,title'
      }).to_tabulatr_json
      result[:data].length.should eq 2
      result[:data].first['id'].should eq p1.id
      result[:data].last['id'].should eq p2.id
      result = subject.find_for_table(Product, {
        sort_by: :title,
        orientation: :desc,
        arguments: 'id,title'
      }).to_tabulatr_json
      result[:data].length.should eq 2
      result[:data].first['id'].should eq p2.id
      result[:data].last['id'].should eq p1.id
    end

    it 'limits the result' do
      3.times do |p|
        Product.create!
      end
      result = subject.find_for_table(Product, {
        arguments: 'id',
        pagesize: 2
      }).to_tabulatr_json
      Product.count.should eq 3
      result[:data].count.should eq 2
    end

    context 'page parameter not given' do
      it 'defaults to the first page' do
        result = subject.find_for_table(Product, {})
        result.__pagination[:page].should eq 1
      end
    end

    context 'page parameter is given' do
      it 'uses it' do
        result = subject.find_for_table(Product, {
          page: 3
        })
        result.__pagination[:page].should eq 3
      end
    end

    context 'append is "false"' do
      it 'converts from string to boolean' do
        result = subject.find_for_table(Product, {
          append: 'false',
          arguments: 'title'
        })
        result.__pagination[:append].should be_false
      end
    end

    context 'append is "true"' do
      it 'converts from string to boolean' do
        result = subject.find_for_table(Product, {
          append: 'true',
          arguments: 'title'
        })
        result.__pagination[:append].should be_true
      end
    end

    it 'filters the data' do
      # article_filter[body][like]:test
      p1 = Product.create!(title: 'foobar')
      p2 = Product.create!(title: 'buzz')
      result = subject.find_for_table(Product, {
        arguments: 'title',
        'product_filter' => {
          'title' => {
            like: 'buz'
          }
        }
      }).to_tabulatr_json
      Product.count.should eq 2
      result[:data].count.should eq 1
      expect(result[:data].first[:id]).to eq(p2.id)
    end

    it 'filters the data with belongs_to filter' do
      v = Vendor.create!(name: 'vnd')
      v2 = Vendor.create!(name: 'vnd_two')
      p1 = Product.create!(title: 'foobar', vendor: v)
      p2 = Product.create!(title: 'buzz', vendor: v2)
      result = subject.find_for_table(Product, {
        arguments: 'title,vendor:name',
        'product_filter' => {
          '__association' => {
            'vendor.name' => 'vnd'
          }
        }
      }).to_tabulatr_json
      Product.count.should eq 2
      Vendor.count.should eq 2
      result[:data].count.should eq 1
      expect(result[:data].first[:id]).to eq(p1.id)
    end

    it 'filters the data with has_many filter' do
      t = Tag.create!(title: 'keyword')
      t2 = Tag.create!(title: 'cloud')
      p1 = Product.create!(title: 'foobar')
      p2 = Product.create!(title: 'buzz')
      p1.tags << t
      p1.save!
      p2.tags << t2
      p2.save!
      result = subject.find_for_table(Product, {
        arguments: 'tags:title',
        'product_filter' => {
          '__association' => {
            'tags.title' => 'cloud'
          }
        }
      }).to_tabulatr_json
      Product.count.should eq 2
      Tag.count.should eq 2
      result[:data].count.should eq 1
      expect(result[:data].first[:id]).to eq(p2.id)
    end

    it 'invokes given batch actions' do
      p1 = Product.create!(title: 'foobar')
      p2 = Product.create!(title: 'buz')
      expect{ |b| subject.find_for_table(Product, {
                    'product_batch' => {
                      foo: ''
                    },
                    'tabulatr_checked' => {
                      checked_ids: '1,2'
                    }
                }, &b)
      }.to yield_control
    end

    it 'doesn\'t invoke when there are no batch actions' do
      p1 = Product.create!(title: 'foobar')
      p2 = Product.create!(title: 'buz')
      expect{ |b| subject.find_for_table(Product, {}, &b)}
        .to_not yield_control
    end
  end
end
