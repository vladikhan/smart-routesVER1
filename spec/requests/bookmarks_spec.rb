require 'rails_helper' 
RSpec.describe "Bookmarks", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:route) { create(:route, user: other_user) }
  let(:venue) { create(:venue) }

  before { sign_in user }

  describe 'POST /bookmarks' do
    context "with valid params (Route)" do
      let(:valid_params) do
        {
          bookmark: 
          {
            item_type: 'Route',
            item_id: route.id
          }
        }
      end

      it 'creates a new bookmark' do
        expect { 
          post bookmark_path, params: valid_params
      }.to change(Bookmark, :count).by(1)
      end

      context 'HTML format' do
        it 'redirects back with success notice' do
          post bookmark_path, params: valid_params

          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq('保存しました！')
        end
      end

      context 'JSON format' do
        it 'returns success response with updated count' do
          post bookmark_path, params: valid_params, as: :json

          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)
          expect(json['success']).to be true
          expect(json['bookmarks_count']).to eq(1)
        end
      end
    end

    context 'with valid params(Venue)' do 
      let(:venue_params) do
        {
          bookmark: {
            item_type: 'Venue',
            item_id: venue.id
          }
        }
      end

      it 'creates bookmark for venue' do
        expect {
          post bookmark_path, params: venue_params
      }.to change(Bookmark, :count).by(1)

      bookmark = Bookmark.last
      expect(bookmark.item_type).to eq('Venue')
      expect(bookmark.item_id).to eq(venue.id)
      end
    end
  end

  context 'with invalid item_type' do
    let(:invalid_params) do 
      {
        bookmark: {
          item_type: 'InvalidType',
          item_id: 999
        }
      }
    end

    it 'does not create bookmarks' do
      expect {
        post bookmark_path, params: invalid_params
    }.not_to change(Bookmark, :count)
    end

    it 'returns error' do
      post bookmark_path, params: invalid_params

      expect(flash[:alert]).to be_present
    end
  end

  context 'authorization checks' do
    context 'when not logged in' do 
      before { sign_out user }

      it 'redirects to login' do
        post bookmark_path, params: {
          bookmark: { item_type: 'Route', item_id: route.id }
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

describe 'GET /bookmarks' do
  let!(:route_bookmark) { create(:bookmark, user: user, item: route) }
  let!(:venue_bookmark) { create(:bookmark, user: user, item: venue) }
  let!(:other_user_bookmark) { create(:bookmark, user: other_user, item: route) }

  context 'when logged in' do 
    it 'returns success' do
      get bookmarks_path

      expect(response).to have_http_status(:success)
    end

    it 'shows only current user bookmarks' do
      get bookmarks_path

      expect(assigns(:bookmarked_items)).to include(route_bookmark, venue_bookmark)
      expect(assigns(:bookmarked_items)).not_to include(other_user_bookmark)
    end

    it 'order bookmarks by created_at desc' do
      newer_bookmark = create(:bookmark, user: user, item: create(:route))

      get bookmarks_path

      expect(assigns(:bookmarked_items).first).to eq(newer_bookmark)
    end

    it 'paginate results (12 per page)' do
      create_list(:bookmark, 15, user: user, item_type: 'Route') do |bookmark, i|
        bookmark.item = create(:route)
      end

      get bookmarks_path, params: { page: 2 }

      expect(assigns(:bookmarked_items).count).to eq(5)
    end

    it 'includes item with images to avoid N+1 queries' do
      get bookmarks_path

      expect(assigns(:bookmarked_items).first.item).to be_present
    end
  end

  context 'authorization checks' do
    context 'when not logged in' do
      before { sign_out user }

      it 'redirects to login' do 
        get bookmarks_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
end
