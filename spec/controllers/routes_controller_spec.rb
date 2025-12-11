require 'rails_helper'

RSpec.describe RoutesController, type: :controller do
  let(:user) { create(:user) }
  let(:city) { create(:city) }
  let!(:route) { create(:route, user: user, city: city) }
  
  describe 'GET #index' do
    let!(:public_route) { create(:route, is_public: true, city: city, user: user) }
    let!(:private_route) { create(:route, is_public: false, city: city, user: user) }
    
    it '公開ルートのみを返す' do
      get :index
      expect(assigns(:routes)).to include(public_route)
      expect(assigns(:routes)).not_to include(private_route)
    end
    
    it 'ステータス200を返す' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'GET #show' do
    it 'ルートを表示する' do
      get :show, params: { id: route.id }
      expect(assigns(:route)).to eq(route)
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'GET #new' do
    context 'ログインユーザー' do
      before { sign_in user }
      
      it '新規作成ページを表示する' do
        get :new
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
    let(:valid_attributes) do
      {
        name: 'テストルート',
        description: 'テスト説明',
        city_id: city.id,
        is_public: true
      }
    end
    
    context '有効な属性の場合' do
      before { sign_in user }
      
      it 'ルートを作成する' do
        expect {
          post :create, params: { route: valid_attributes }
        }.to change(Route, :count).by(1)
      end
      
      it 'ルート詳細ページにリダイレクトする' do
        post :create, params: { route: valid_attributes }
        expect(response).to redirect_to(Route.last)
      end
      
      it 'フラッシュメッセージを表示する' do
        post :create, params: { route: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end
  end
  
  describe 'PATCH #update' do
    context 'オーナーの場合' do
      before { sign_in user }
      
      it 'ルートを更新する' do
        patch :update, params: { id: route.id, route: { name: '更新後' } }
        route.reload
        expect(route.name).to eq('更新後')
      end
    end
    
    context '他のユーザーの場合' do
      let(:other_user) { create(:user) }
      before { sign_in other_user }
      
      it 'アクセスを拒否する' do
        patch :update, params: { id: route.id, route: { name: '更新後' } }
        expect(response).to redirect_to(routes_path)
      end
    end
  end
  
  describe 'DELETE #destroy' do
    before { sign_in user }
    
    it 'ルートを削除する' do
      route_to_delete = create(:route, user: user, city: city)
      expect {
        delete :destroy, params: { id: route_to_delete.id }
      }.to change(Route, :count).by(-1)
    end
    
    it 'ルート一覧にリダイレクトする' do
      delete :destroy, params: { id: route.id }
      expect(response).to redirect_to(routes_path)
    end
  end
end
