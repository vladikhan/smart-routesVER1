require 'rails_helper'

RSpec.describe Review::Operation::Create do
  let(:user) { create(:user) }
  let(:venue) { create(:venue, :restaurant) }

  describe 'Success path: Validate -> Persist -> Notify' do
    let(:valid_params) do
      {
        reviewable_type: 'Venue',
        reviewable_id: venue.id,
        text: 'とても美味しかったです！雰囲気も最高でした。',
      }
    end

    it 'creates a new review' do
      expect {
        result = described_class.call(params: valid_params, current_user: user)
        expect(result).to be_success
      }.to change(Review, :count).by(1)
    end

    it 'creates review with correct attributes' do
      result = described_class.call(params: valid_params, current_user: user)
      review = result[:model]
      expect(review.user).to eq(user)
      expect(review.reviewable).to eq(venue)
      expect(review.text).to eq(valid_params[:text])
    end

    context 'activity tracking' do
      it 'creates activity record' do
        expect {
          described_class.call(params: valid_params, current_user: user)
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.user).to eq(user)
        expect(activity.key).to eq('review.create')
        # Исправил опечатку ecpect -> expect
        expect(activity.trackable_type).to eq('Review') 
      end
    end
  end

  describe 'Validation failures' do
    context 'when text is missing' do
      it 'fails validation' do
        result = described_class.call(
          params: { reviewable_type: 'Venue', reviewable_id: venue.id },
          current_user: user
        )
        expect(result).to be_failure
        expect(result['contract.default'].errors[:text]).to be_present
      end
    end

    context 'when reviewable does not exist' do # Убрал лишние скобки
      it 'fails validation' do
        result = described_class.call(
          params: { reviewable_type: 'Venue', reviewable_id: 999999, text: 'とても美味しかったです' },
          current_user: user
        )
        expect(result).to be_failure
        expect(result['contract.default'].errors[:reviewable_id]).to include('が存在しません')
      end
    end
  end

  describe 'Authorization' do
    context 'when not logged in' do
      it 'fails authorization' do # Добавил пропущенный блок it
        result = described_class.call(
          params: { reviewable_type: 'Venue', reviewable_id: venue.id, text: 'レビュー' },
          current_user: nil
        )
        expect(result).to be_failure
      end
    end
  end

  describe 'Review with images' do # Переименовал логически (это не Rollback, а проверка вложений)
    let(:params_with_images) do
      {
        reviewable_type: 'Venue',
        reviewable_id: venue.id,
        text: '美味しいかったです！',
        images: [
          fixture_file_upload('spec/fixtures/files/test_image.png', 'image/png')
        ]
      }
    end

    it 'creates review with attached images' do
      result = described_class.call(params: params_with_images, current_user: user)
      expect(result).to be_success
      review = result[:model]
      expect(review.review_images.count).to eq(1)
    end
  end
end # Вот этот end закрывает RSpec.describe