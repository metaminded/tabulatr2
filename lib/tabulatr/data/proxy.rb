class Data::Proxy

  def initialize(record)
    self.class._init
    @record = record
  end

  def self._init
    return if @_initialized
    @_initialized = true
    include ActionView::Helpers
    include Rails.application.helpers
    include Rails.application.routes.url_helpers
  end

  def method_missing(*args)
    @record.send *args
  end
end
