require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    context "with public routes" do
      let!(:user) { create(:user) }
      let!(:public_route1) { create(:route, is_public: true, user: user, created_at: 1.day.ago, view_count: 100) }
      let!(:public_route2) { create(:route, is_public: true, user: user, created_at: 2.days.ago, view_count: 50) }
      let!(:private_route) { create(:route, is_public: false, user: user) }

      before { get :index }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns trending routes" do
        expect(assigns(:trending_routes)).to include(public_route1, public_route2)
      end

      it "assigns recent routes" do
        expect(assigns(:recent_routes)).to include(public_route1, public_route2)
      end

      it "does not include private routes" do
        expect(assigns(:trending_routes)).not_to include(private_route)
        expect(assigns(:recent_routes)).not_to include(private_route)
      end

      it "assigns trending routes in descending order" do
        expect(assigns(:trending_routes).first).to eq(public_route1)
      end

      it "excludes private routes from search results" do
        get :index, params: { q: private_route.name }
        expect(assigns(:search_results)).not_to include(private_route) if assigns(:search_results)
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end
    end
  end

  describe "GET #search" do
    # Create unique city for each test context
    let!(:city) { create(:city) }
    let!(:user) { create(:user) }
    let!(:route_in_city) { create(:route, city: city, is_public: true, user: user, estimated_cost: 50000) }
    let!(:route_expensive) { create(:route, city: city, is_public: true, user: user, estimated_cost: 150000) }
    
    it "returns results as JSON" do
      get :search, params: { q: route_in_city.name }, format: :json
      expect(response.content_type).to include('application/json')
    end

    it "searches by city name" do
      get :search, params: { city: city.name }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.map { |r| r['id'] }).to include(route_in_city.id)
    end

    it "searches by budget range" do
      get :search, params: { min_budget: 40000, max_budget: 60000 }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.map { |r| r['id'] }).to include(route_in_city.id)
    end

    it "excludes routes outside budget" do
      get :search, params: { min_budget: 40000, max_budget: 60000 }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.map { |r| r['id'] }).not_to include(route_expensive.id)
    end
  end
end