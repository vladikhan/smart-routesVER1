class Tag < ApplicationRecord
	has_many :entity_tags, dependent: :destroy
	has_many :venues, through: :entity_tags, source: :entity, source_type: 'Venue'
	has_many :routes, through: :entity_tags, source: :entity, source_type: 'Route'
	has_many :venue_tags
	has_many :venues, through: :venue_tags

	validates :parameter, presence: true, uniqueness: true, length: { maximum: 50 }
	validates :parameter, format: {
		with: /\A[a-z0-9_]+\z/,
		message:  "小文字英数字とアンダースコアのみ使用可能です" 
	}

	# スコープ
	scope :popular, -> {
		joins(:entity_tags)
			.group('tags.id')
			.order('COUNT(entity_tags.id) DESC')
	}

	# メソッド
	 def display_name
		"##{parameter}"
	 end
end
