require 'rails_helper'

RSpec.describe EntityTag, type: :model do
  it 'has a valid factory' do
    expect(build(:entity_tag)).to be_valid
  end
end
