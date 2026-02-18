require 'rails_helper'

RSpec.describe Follower::Operation::Create do
  let(:follower_user) { create(:user) }
  let(:following_user) { create(:user) }

  describe 'Success path: Validate -> Persist -> Notify' do
    it 'creates a new follower relationship' do
      expect {
        result = described_class.call(
          params: { following_id: following_user.id },
          current_user: follower_user
        )
        
        expect(result).to be_success
      }.to change(Follower, :count).by(1)
    end

    it 'creates follower with pending status by default' do
      result = described_class.call(
        params: { following_id: following_user.id },
        current_user: follower_user
      )
      
      follower = result[:model]
      expect(follower.status).to eq('pending')
      expect(follower.follower_id).to eq(follower_user.id)
      expect(follower.following_id).to eq(following_user.id)
    end

    it 'increments following_count for follower' do
      expect {
        described_class.call(
          params: { following_id: following_user.id },
          current_user: follower_user
        )
      }.to change { follower_user.reload.following_count }.by(1)
    end

    it 'creates notification for the followed user' do
      expect {
        described_class.call(
          params: { following_id: following_user.id },
          current_user: follower_user
        )
      }.to change(Notification, :count).by(1)
      
      notification = Notification.last
      expect(notification.user_id).to eq(following_user.id)
      expect(notification.actor_id).to eq(follower_user.id)
      expect(notification.notification_type).to eq('follow_request')
    end

    context 'with ActionCable broadcast' do
      it 'broadcasts notification via NotificationsChannel' do
        expect {
          described_class.call(
            params: { following_id: following_user.id },
            current_user: follower_user
          )
      }.to have_broadcasted_to("notifications_#{following_user.id}").with(
        hash_including(type: 'follow_request')
      )
      end
    end
  end

  describe 'Validation failures' do
    context 'when following_id is missing' do
      it 'fails validation' do
        result = described_class.call(
          params: {},
          current_user: follower_user
        )
        
        expect(result).to be_failure
        expect(result['contract.default'].errors[:following_id]).to be_present
      end
    end

    context 'when trying to follow yourself' do
      it 'fails validation' do
        result = described_class.call(
          params: { following_id: follower_user.id },
          current_user: follower_user
        )
        
        expect(result).to be_failure
        expect(result['contract.default'].errors[:following_id])
          .to include('自分自身をフォローすることはできません')
      end
    end

    context 'when following_id does not exist' do
      it 'fails validation' do
        result = described_class.call(
          params: { following_id: 999999 },
          current_user: follower_user
        )
        
        expect(result).to be_failure
        expect(result['contract.default'].errors[:following_id])
          .to include('ユーザーが存在しません')
      end
    end

    context 'when already following' do
      let(:active_user) { create(:user) }
      let(:target_user) { create(:user) }

      before do
        create(:follower, follower: active_user, following: target_user)
      end

      it 'fails validation' do
        result = described_class.call(
          params: { following_id: target_user.id },
          current_user: active_user
        )
        
        puts  result['contract.default'].errors.messages if result.failure?

        expect(result).to be_failure
        expect(result['contract.default'].errors[:following_id])
          .to include('すでにフォローしています')
      end
    end
  end

  describe 'Authorization' do
    context 'when current_user is not logged in' do
      it 'fails authorization' do
        result = described_class.call(
          params: { following_id: following_user.id },
          current_user: nil
        )
        expect(result).to be_failure
      end
    end
  end

  describe 'Rollback on notification failure' do
    before do
      allow(Notification::Operation::Create).to receive(:call).and_return(
        Trailblazer::Operation::Result.new(
          false, {})
      )
    end

    it 'it still creates follower even if notification fails' do
      allow(Notification::Operation::Create).to receive(:call).and_return(
        Trailblazer::Operation::Result.new(
          false, {}
        )
      )
      expect {
        result = described_class.call(
          params: { following_id: following_user.id },
          current_user: follower_user
        )
        
        expect(result).to be_success
      }.to change(Follower, :count).by(1)
    end

    it 'increments counters even if notification fails' do

      allow(Notification::Operation::Create).to receive(:call).and_return(
        Trailblazer::Operation::Result.new(
          false, {}
        )
      )
      expect {
        described_class.call(
          params: { following_id: following_user.id },
          current_user: follower_user
        )
      }.to change { follower_user.reload.following_count }.by(1)
    end
  end
end