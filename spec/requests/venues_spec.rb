require 'rails_helper'

RSpec.describe 'Venues', type: :request do
  # Помни: let! создается СРАЗУ, let — только при вызове.
  let!(:city) { create(:city) }
  let!(:district) { city.districts.first || create(:district, city: city) }
  
  # Создаем пользователя-админа (или того, у кого есть права)
  let(:admin) { create(:user, :admin) }

  let!(:restaurant) do
    create(:venue,
           district: district,
           geo_lat: 35.0,
           geo_lng: 135.0,
           venue_type: 'restaurant')
  end

  let!(:attraction) do
    create(:venue,
           district: district,
           geo_lat: 35.01,
           geo_lng: 135.01,
           venue_type: 'attraction')
  end

  # --- GET запросы обычно публичные, sign_in не нужен ---
  describe 'GET /venues' do
    it 'shows venue index' do
      get venues_path
      expect(response).to have_http_status(:success)
    end

    it 'displays venues' do
      get venues_path
      expect(response.body).to include(restaurant.name)
    end
  end

  describe 'GET /venues/:id' do
    it 'shows venue details' do
      get venue_path(restaurant)
      expect(response).to have_http_status(:success)
    end

    context 'when venue does not exist' do
      it 'redirects to venues index with alert' do
        get venue_path(id: 999999)
        expect(response).to redirect_to(venues_path)
        expect(flash[:alert]).to eq('店舗が見つかりませんでした')
      end
    end
  end

  # --- PATCH требует прав доступа ---
  describe 'PATCH /venues/:id' do
    # Логинимся перед каждым тестом внутри этого блока
    before { sign_in admin }

    let(:valid_params) do
      {
        venue: {
          name: 'Updated Venue Name',
          description: 'Updated description',
          district_id: district.id
        }
      }
    end

    it 'updates venue and redirects with notice' do
      patch venue_path(restaurant), params: valid_params
      expect(response).to redirect_to(venue_path(restaurant))
      expect(flash[:notice]).to eq('情報を更新しました')
      expect(restaurant.reload.name).to eq('Updated Venue Name')
    end

    context 'with invalid params' do
      it 're-renders edit with unprocessable_entity' do
        invalid_params = { venue: { name: '', description: '', district_id: nil } }
        patch venue_path(restaurant), params: invalid_params
        
        # Теперь вернет 422, так как sign_in пропустил нас через Pundit
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq('入力内容にエラーがあります')
      end
    end
  end

  describe 'DELETE /venues/:id/delete_photo' do
    before { sign_in admin } # Тут тоже нужна авторизация, если это защищенное действие

    it 'redirects back to venue' do
      delete delete_photo_venue_path(restaurant), params: { photo_id: 'nonexistent' }
      expect(response).to redirect_to(venue_path(restaurant))
    end
  end
end