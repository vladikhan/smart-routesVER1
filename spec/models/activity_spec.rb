require 'rails_helper'

RSpec.describe Activity, type: :model do
  it 'has a valid factory' do
    expect(build(:activity)).to be_valid
  end
end