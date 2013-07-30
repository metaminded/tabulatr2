class ActionController::Base
  def tabulatr_for(klaz, serializer: nil, **options)
    respond_to do |format|
      format.json {
        records = klaz.find_for_table(params, options)
        render json: records.to_tabulatr_json(serializer)
      }
      format.html {
        render action: 'index'
      }
    end
  end
end
