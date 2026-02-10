require 'rails_helper'

RSpec.describe 'Messenger', type: :system do
  let(:me) { create(:user) }
  let(:friend) { create(:dm_room, sender: me, receiver: friend) }

  before do 
    driven_by(:cuprite)
    sign_in me
  end

  it 'メッセージを送信し、チャットでそれを確認することができます' do
    visit dm_room_path(room)

    fill_in "message-input", with: 'Hello!'
    click_button "Send"

    expect(page).to have_content("Hello! how are U?")

    expect(DmMessage.last.message).to eq("Hello! how are U?")
  end
end