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
    end
  end

  def self.string_to_boolean str
    if str.downcase == 'true'
      str = true
    elsif str.downcase == 'false'
      str = false
    end
    str
  end
end
