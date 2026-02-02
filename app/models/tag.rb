#encoding: UTF-8
class Tag < ApplicationRecord
  has_many :entity_tags, dependent: :destroy
  has_many :routes, through: :entity_tags, source: :entity, source_type: 'Route'
  has_many :venues, through: :entity_tags, source: :entity, source_type: 'Venue'

  validates :parameter, presence: true, uniqueness: true

  def display_name
    case parameter
    when 'ramen' then 'ラーメン'
    when 'culture' then '文化'
    when 'history' then '歴史'
    when 'temple' then '寺院'
    when 'shrine' then '神社'
    when 'food' then 'グルメ'
    when 'shopping' then 'ショッピング'
    when 'nature' then '自然'
    when 'nightlife' then 'ナイトライフ'
    when 'cafe' then 'カフェ'
    else
      parameter.capitalize
    end
  end

  def name
    display_name
  end
end
