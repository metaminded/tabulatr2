require 'rails_helper'

describe Tabulatr::ParamsBuilder do
  it 'accepts an argument which is in the ALLOWED_PARAMS array' do
    pb = nil
    expect{pb = Tabulatr::ParamsBuilder.new(filter: false)}.to_not raise_error
    expect(pb.filter).to be_falsey
  end

  it 'does not accept a param which is not in the ALLOWED_PARAMS array' do
    stub_const('Tabulatr::ParamsBuilder::ALLOWED_PARAMS', [:allowed_params])
    expect{Tabulatr::ParamsBuilder.new(non_allowed_param: 'test')}.to raise_error(ArgumentError)
  end

  it 'does not accept a param which is in the DEPRECATED_PARAMS array' do
    stub_const('Tabulatr::ParamsBuilder::DEPRECATED_PARAMS', [:deprecated_param])
    expect{Tabulatr::ParamsBuilder.new(deprecated_param: 'test')}.to raise_error(NoMethodError)
  end
end