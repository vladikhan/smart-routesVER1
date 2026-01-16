# app/helpers/reviews_helper.rb
module ReviewsHelper
  def render_stars(rating)
    full_stars = rating.to_i
    half_star = (rating % 1) >= 0.5 ? 1 : 0
    empty_stars = 5 - full_stars - half_star

    html = ''
    html += '⭐' * full_stars
    html += '✨' * half_star
    html += '☆' * empty_stars

    html.html_safe
  end
end
