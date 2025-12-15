require 'rails_helper'

RSpec.describe RoutesController, type: :controller do
  let(:user) { create(:user) }
  let(:city) { create(:city) }
  let!(:route) { create(:route, user: user, city: city) }
  
  describe 'GET #index' do
    let!(:public_route) { create(:route, is_public: true, city: city, user: user) }
    let!(:private_route) { create(:route, is_public: false, city: city, user: user) }
    
    it 'публичные маршруты отображаются' do
      get :index
      expect(assigns(:routes)).to include(public_route)
      expect(assigns(:routes)).not_to include(private_route)
    end
    
    it 'возвращает статус 200' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'GET #show' do
    before { get :show, params: { id: route.id } }
    
    it 'отображает маршрут' do
      expect(assigns(:route)).to eq(route)
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'GET #new' do
    context 'авторизованный пользователь' do
      before do
        sign_in user
        get :new
      end
      
      it 'показывает страницу создания' do
        expect(response).to have_http_status(:success)
      end
      
      it 'загружает города' do
        expect(assigns(:cities)).to be_present
      end
      
      it 'загружает места' do
        expect(assigns(:venues)).to be_present
      end
    end
    
    context 'неавторизованный пользователь' do
      it 'перенаправляет на логин' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        name: 'Тестовый маршрут',
        description: 'Описание',
        city_id: city.id,
        estimated_duration: 300,
        estimated_cost: 5000,
        is_public: true
      }
    end
    
    context 'с валидными атрибутами' do
      before { sign_in user }
      
      it 'создает маршрут' do
        expect {
          post :create, params: { route: valid_attributes }
        }.to change(Route, :count).by(1)
      end
      
      it 'перенаправляет на страницу маршрута' do
        post :create, params: { route: valid_attributes }
        expect(response).to redirect_to(Route.last)
      end
      
      it 'показывает сообщение' do
        post :create, params: { route: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end
    
    context 'без аутентификации' do
      it 'перенаправляет на логин' do
        post :create, params: { route: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'GET #edit' do
    context 'владелец маршрута' do
      before do
        sign_in user
        get :edit, params: { id: route.id }
      end
      
      it 'показывает страницу редактирования' do
        expect(response).to have_http_status(:success)
      end
      
      it 'загружает список городов' do
        expect(assigns(:cities)).to be_present
      end
      
      it 'загружает список мест' do
        expect(assigns(:venues)).to be_present
      end
    end
    
    context 'другой пользователь' do
      let(:other_user) { create(:user) }
      
      before do
        sign_in other_user
        get :edit, params: { id: route.id }
      end
      
      it 'запрещает доступ' do
        expect(response).to redirect_to(routes_path)
        expect(flash[:alert]).to be_present
      end
    end
    
    context 'без аутентификации' do
      it 'перенаправляет на логин' do
        get :edit, params: { id: route.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'PATCH #update' do
    context 'владелец маршрута' do
      before { sign_in user }
      
      it 'обновляет маршрут' do
        patch :update, params: { 
          id: route.id, 
          route: { name: 'Обновленное название' } 
        }
        route.reload
        expect(route.name).to eq('Обновленное название')
      end
      
      it 'перенаправляет на маршрут' do
        patch :update, params: {
          id: route.id,
          route: { name: 'Обновлено' }
        }
        expect(response).to redirect_to(route)
      end
    end
    
    context 'другой пользователь' do
      let(:other_user) { create(:user) }
      
      before { sign_in other_user }
      
      it 'запрещает доступ' do
        patch :update, params: { 
          id: route.id, 
          route: { name: 'Обновлено' } 
        }
        expect(response).to redirect_to(routes_path)
      end
    end
    
    context 'без аутентификации' do
      it 'перенаправляет на логин' do
        patch :update, params: { 
          id: route.id, 
          route: { name: 'Обновлено' } 
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'DELETE #destroy' do
    context 'владелец маршрута' do
      before { sign_in user }
      
      it 'удаляет маршрут' do
        route_to_delete = create(:route, user: user, city: city)
        expect {
          delete :destroy, params: { id: route_to_delete.id }
        }.to change(Route, :count).by(-1)
      end
      
      it 'перенаправляет на список маршрутов' do
        delete :destroy, params: { id: route.id }
        expect(response).to redirect_to(routes_path)
      end
    end
    
    context 'без аутентификации' do
      it 'перенаправляет на логин' do
        delete :destroy, params: { id: route.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
