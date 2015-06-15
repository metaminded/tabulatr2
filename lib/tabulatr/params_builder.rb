module Tabulatr
  class ParamsBuilder
    ALLOWED_PARAMS    = [:header, :filter, :sortable, :data_html,
                         :header_html, :filter_sql, :sort_sql, :sql, :width,
                         :align, :wrap, :format, :filter_label, :name, :classes]
    DEPRECATED_PARAMS = []

    attr_accessor *ALLOWED_PARAMS

    def initialize(params = {})
      apply_params(params)
    end

    def update(params = {})
      apply_params(params)
    end

    private

    def style_options
      self.data_html ||= {}
      self.header_html ||= {}
      self.data_html[:style] ||= ''
      self.header_html[:style] ||= ''
      apply_style_option('text-align', align)
      apply_style_option('width', width)
      apply_style_option('white-space', wrap)
    end

    def apply_params(params)
      params.each do |k, v|
        if DEPRECATED_PARAMS.include?(k.to_sym)
          self.public_send(k)
        elsif ALLOWED_PARAMS.exclude?(k.to_sym)
          raise ArgumentError, "`#{k}` is not allowed as a parameter"
        else
          self.public_send("#{k}=", v)
        end
      end
      style_options
    end

    def apply_style_option(attribute, value)
      if value.present?
        self.header_html[:style].concat("#{attribute}: #{value};")
        self.data_html[:style].concat("#{attribute}: #{value};")
      end
    end
  end
end
