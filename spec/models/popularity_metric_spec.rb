require 'rails_helper'

RSpec.describe PopularityMetric, type: :model do
  it 'has a valid factory' do
    expect(build(:popularity_metric)).to be_valid
  end
end
