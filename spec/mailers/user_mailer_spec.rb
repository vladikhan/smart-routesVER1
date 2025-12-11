require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'verification_code_email' do
    let(:user) do
      create(:user).tap do |u|
        u.update_columns(
          verification_code: '123456',
          verification_code_sent_at: Time.current
        )
      end
    end
    let(:mail) { UserMailer.verification_code_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('[Smart Routes] メールアドレス確認コード')
      expect(mail.to).to eq([user.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('123456')
    end
  end
end
