class ActionController::Base
  def tabulatr_for(klaz, tabulatr_data_class: nil, serializer: nil, render_action: nil, &block)
    respond_to do |format|
      format.json {
        records = klaz.tabulatr(tabulatr_data_class).data_for_table(params, &block)
        render json: records.to_tabulatr_json(serializer)
      }
      format.html {
        render action: render_action || action_name
      }
    end
  end
end
