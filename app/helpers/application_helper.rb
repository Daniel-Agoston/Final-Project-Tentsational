module ApplicationHelper
  def render_stars(rating)
    return '☆☆☆☆☆' if rating.nil?

    full_stars = rating.round
    empty_stars = 5 - full_stars
    ('★' * full_stars) + ('☆' * empty_stars)
  end
end
