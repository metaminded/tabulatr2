class ActionController::Base
  def tabulatr_for(klaz, serializer: nil, **options, &block)
    respond_to do |format|
      format.json {
        records = klaz.find_for_table(params, options, &block)
        render json: records.to_tabulatr_json(serializer)
      }
      format.html {
        render action: options[:action] || 'index'
      }
    end
  end
end
