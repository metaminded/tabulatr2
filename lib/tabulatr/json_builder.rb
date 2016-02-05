#--
# Copyright (c) 2010-2014 Peter Horn & Florian Thomas, metaminded UG
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Tabulatr::JsonBuilder
  def self.build(data, klass, requested_attributes, id="id")
    if klass && ActiveModel.const_defined?(:ArraySerializer)
      ActiveModel::ArraySerializer.new(data,
        { root: "data", meta: data.__pagination,
          each_serializer: klass
        }).as_json
    else
      attrs = build_hash_from requested_attributes, id
      result = []
      data.each do |f|
        tmp = {}
        attrs.each do |at|
          insert_attribute_in_hash(at, f, tmp)
        end
        tmp['_row_config'] = f['_row_config']
        result << tmp
      end
      { data: result, meta: data.__pagination }
    end
  end

  private

  def self.build_hash_from requested_attributes, id
    attrs = []
    id_included = false
    requested_attributes ||= ''
    requested_attributes.split(',').each do |par|
      if par.include? ':'
        relation, action = par.split(':')
        attrs << {action: action, relation: relation}
      else
        id_included = true if par == id
        attrs << {action: par}
      end
    end
    attrs << {action: id} unless id_included
    attrs
  end

  def self.insert_attribute_in_hash at, f, r={}
    action = at[:action].to_sym
    relation = at[:relation].try(:to_sym)
    if at.has_key? :relation
      check_if_attribute_is_in_hash(f, relation)
      check_if_attribute_is_in_hash(f[relation], action) if action != :id
      set_value_at_key(r, f[relation][action], "#{at[:relation]}:#{at[:action]}")
    else
      check_if_attribute_is_in_hash(f, action) if [:checkbox, :id].exclude?(action)
      set_value_at_key(r, f[action], at[:action])
    end
    r
  end

  private

  def self.check_if_attribute_is_in_hash hash, key
    if !hash.has_key?(key)
      raise Tabulatr::RequestDataNotIncludedError.raise_error(key, hash)
    end
  end

  def self.set_value_at_key hash, value, key
    begin
      hash[key] = value
    rescue TypeError, NoMethodError => e
      raise Tabulatr::RequestDataNotIncludedError.raise_error(key, value)
    end
  end
end
