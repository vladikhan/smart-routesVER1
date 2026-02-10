require 'rails_helper'

RSpec.describe Share, type: :model do
  it 'has a valid factory' do
    expect(build(:share)).to be_valid
  end
end