require 'rails_helper'

RSpec.describe Follower, type: :model do
  it 'has a valid factory' do
    expect(build(:follower)).to be_valid
  end
end
