class PagesController < ApplicationController
  def home
    result = Page::Operation::Home.call
    
    # Распаковываем данные из результата операции
    @stats           = result[:stats]
    @featured_routes = result[:featured_routes]
    @popular_venues  = result[:popular_venues]
    @recent_routes   = result[:recent_routes]
  end

  def logout_confirm
    # Просто рендерит вьюху
  end
end