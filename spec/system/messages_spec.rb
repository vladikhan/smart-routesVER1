require 'rails_helper'

RSpec.describe 'Messenger', type: :system do
  let(:me) { create(:user) }
  let(:other_user) { create(:user) }

  let(:room) { create(:dm_room, sender: me, receiver: other_user) }

  before do 
    driven_by(:selenium_chrome_headless)
    sign_in me
  end
end