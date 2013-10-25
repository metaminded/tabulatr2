#--
# Copyright (c) 2010-2014 Peter Horn & Florian Thomas, Provideal GmbH
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

module Tabulatr::Utility
  def self.like_statement
    case ActiveRecord::Base.connection.class.to_s
    when "ActiveRecord::ConnectionAdapters::MysqlAdapter",
         "ActiveRecord::ConnectionAdapters::Mysql2Adapter",
         "ActiveRecord::ConnectionAdapters::SQLiteAdapter",
         "ActiveRecord::ConnectionAdapters::SQLite3Adapter"
         then 'LIKE'
    when "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter" then 'ILIKE'
    else
      warn("Tabulatr Warning: Don't know which LIKE operator to use for the ConnectionAdapter '#{ActiveRecord::Base.connection.class}'.\n")
      'LIKE'
    end
  end

  def self.string_to_boolean str
    if str.downcase == 'true'
      true
    elsif str.downcase == 'false'
      false
    end
  end
end
