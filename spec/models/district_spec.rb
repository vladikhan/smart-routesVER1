require 'rails_helper'

RSpec.describe District, type: :model do
  it { should belong_to(:city) }
  it { should validate_presence_of(:name) }
end
