require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    # Используем let!, чтобы данные создались до вызова get
    let!(:featured_routes) { create_list(:route, 3, is_featured: true, is_public: true, featured_order: 1) }
    let!(:popular_venues)  { create_list(:venue, 3, status: 'approved', average_rating: 5.0) }
    let!(:recent_routes)   { create_list(:route, 5, is_public: true) }

    subject(:request) { get root_path }

    it 'returns success and assigns all necessary data' do
      request
      expect(response).to have_http_status(:success)
      
      # Проверяем все основные переменные в одном тесте, чтобы не плодить запросы
      expect(assigns(:featured_routes)).to match_array(featured_routes)
      expect(assigns(:popular_venues)).to match_array(popular_venues)
      expect(assigns(:stats)).to include(:total_routes, :total_venues, :total_users)
    end

    describe 'Content logic' do
      before { request }

      it 'orders featured routes by featured_order' do
        # Создаем один с приоритетом повыше
        top_route = create(:route, is_featured: true, is_public: true, featured_order: 0)
        get root_path # Перезапрашиваем
        expect(assigns(:featured_routes).first).to eq(top_route)
      end

      it 'filters recent routes' do
        private_route = create(:route, is_public: false)
        deleted_route = create(:route, is_deleted: true)
        
        get root_path
        expect(assigns(:recent_routes)).not_to include(private_route, deleted_route)
      end
    end

    describe 'Performance & Caching' do
      it 'caches stats' do
        # Пример того, как реально протестировать кэш Rails
        allow(Rails.cache).to receive(:fetch).with('homepage_stats', expires_in: 1.hour).and_call_original
        get root_path
        expect(Rails.cache).to have_received(:fetch)
      end
    end

    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'responds successfully' do
        request
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /logout_confirm' do
    context 'when authenticated' do
      before { sign_in create(:user) }

      it 'renders the confirmation page' do
        get logout_confirm_path
        expect(response).to render_template(:logout_confirm)
      end
    end

    context 'when guest' do
      it 'redirects to root or login' do
        get logout_confirm_path
        # Обычно такие страницы не показывают гостям
        expect(response).to redirect_to(root_path)
      end
    end
  end
end