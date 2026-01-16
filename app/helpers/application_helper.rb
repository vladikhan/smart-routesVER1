module ApplicationHelper
  def render_stars(rating)
    content_tag :div, class: 'star-rating' do
      (1..5).map do |i|
        content_tag :span, i <= rating ? '*' : '+', class: i <= rating ? 'star-filled' : 'star-empty'
      end
    end
  end
end
