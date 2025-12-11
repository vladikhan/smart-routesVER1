# Encoding: UTF-8
require 'rails_helper'

RSpec.describe RoutesController, type: :controller do
  let(:user) { create(:user) }
  let(:city) { create(:city, :with_districts) }
  let(:route) { create(:route, user: user, city: city) }

  describe 'GET #index' do
    let!(:public_routes) { create_list(:route, 5, is_public: true, city: city) }
    let!(:private_routes) { create_list(:route, :private,  city: city) }

    it '公開ルートのみを返す' do
      get :index
      expect(assigns(:routes)).to match_array(public_routes)
      expect(assigns(:routes)).not_to include(private_routes)
    end

    it 'ステータス200を返す' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'リートを表示する' do
      get :show, params: { id: route.id }
      expect(assigns(:route)).to eq(route)
      expect(response).to have_http_status(:success)
    end

    it '閲覧数をインクリメントする' do
      expect {
        get :show, params: { id: route.id }
    }.to change { route.reload.view_count }.by(1)
    end
  end

  describe 'GET #new' do
  context 'ログインユーザー' do
    before { sign_in user }

    it '新規作成ページを表示する' do
      get :new
      expect(assigns(:route)).to be_a_new(Route)
      expect(response).to have_http_status(:success)
    end
  end

  context '未ログインユーザー' do
    it 'ログインページにリダイレクトする' do
      get :new
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

describe 'POST #create' do
before { sign_in user }

  let(:valid_attributes) do
    {
      name: 'テストルート',
      description: '説明',
      estimated_duration: 120,
      is_public: true,
      city_id: city.id
    }
  end

  context '有効な属性の場合' do
    it 'ルートを作成する' do
      expect {
        post :create, params: { route: valid_attributes }
      }.to change(Route, :count).by(1)
    end

    it 'ルート詳細ページをリダイレクトする' do
      post :create, params: { route: valid_attributes }
      expect(response).to redirect_to(Route.last)
    end

    it 'フラッシュメッセージを表示する' do
      post :create, params: { route: valid_attributes }
      expect(flash[:notice]).to be_present
    end
  end

  context '無効なパラメータ' do
    it 'ルートを作成しない' do
      expect {
        post :create, params: { route: { name: '' } }
      }.not_to change(Route, :count)
    end
  end
end

describe 'PATCH #update' do
  before {sign_in user }
  context 'オーナーの場合' do
    it 'ルートを更新する' do
      patch :update, params: { id: route.id, route: { name: '更新されたルート' } }
      expect(route.reload.name).to eq('更新されたルート')
    end
  end

  context '他のユーザーの場合' do
    let(:other_user) {create(:user) }

    before { sign_in other_user }

    it 'アクセスを拒否する' do
      patch :update, params: { id: route.id, route: { name: '更新' } }
      expect(response).to redirect_to(routes_path)
      expect(flash[:alert]).to be_present
    end
  end
end

  describe 'DELETE #destroy' do
    let!(:route_to_delete) { create(:route, user: user, city: city) }

    before { sing_in user }

    it 'ルートを削除する' do
      expect {
        delete :destroy, params: { id: route_to_delete.id }
      }.to change(Route, :count).by(-1)
    end

    it 'ルート一覧にリダイレクトする' do
      delete :destroy, params: { id: route_to_delete.id }
      expect(response).to redirect_to(routes_path)
    end
  end
end