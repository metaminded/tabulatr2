require 'whiny_hash'

module Tabulatr
  module Settings

    # Hash keeping the defaults for the table options, may be overriden in the
    # table_for call
    TABLE_OPTIONS = WhinyHash.new({ # WhinyHash.new({
      :filter => true,                   # false for no filter row at all
      :search => true,                   # show fuzzy search field
      :paginate => false,                # true to show paginator
      :pagesize => 20,                   # default pagesize
      :sortable => true,                 # true to allow sorting (can be specified for every sortable column)
      :batch_actions => false,           # :name => value hash of batch action stuff
      :footer_content => false,          # if given, add a <%= content_for <footer_content> %> before the </table>
      :path => '#'                       # where to send the AJAX-requests to
    })

    # Stupid hack
    SQL_OPTIONS = WhinyHash.new({
      :like => nil
    })

    def self.table_options(n=nil)
      TABLE_OPTIONS.merge!(n) if n
      TABLE_OPTIONS
    end

    def self.sql_options(n=nil)
      SQL_OPTIONS.merge!(n) if n
      SQL_OPTIONS
    end
    def sql_options(n=nil) self.class.sql_options(n) end

    COLUMN_PRESETS = {}
    def self.column_presets(n=nil)
      COLUMN_PRESETS.merge!(n) if n
      COLUMN_PRESETS
    end
    def column_presets(n=nil) self.class.column_presets(n) end
    def self.column_preset_for(name)
      h = COLUMN_PRESETS[name.to_sym]
      return {} unless h
      return h if h.is_a? Hash
      COLUMN_PRESETS[h] || {}
    end
  end
end
