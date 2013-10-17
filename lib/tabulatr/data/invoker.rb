class Tabulatr::Data::Invoker
  def initialize(batch_action, ids)
    @batch_action = batch_action.to_sym
    @ids = ids
  end

  def method_missing(name, *args, &block)
    if @batch_action == name
      yield(@ids)
    end
  end
end


