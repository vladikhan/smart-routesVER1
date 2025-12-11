class PopularityMetric < ApplicationRecord

	belongs_to :entity, polymorphic: true

	validates:entity_type, uniqueness: { scope: :entity_id }

	#人気スコア計算メソッド
	def calculate_popularity_score
		score = 0
		score += view_count * 0.1
		score += like_count * 1.0
		score += save_count * 2.5
		score += comment_count * 1.5
		score += download_count * 2.0
	
	  # 最近の活動にボーナス
		if updated_at > 7.days.ago
			score *= 1.5
		elsif updated_at > 30.days.ago
			score *= 1.2
		end

		update(popularity_score: score)
	end

	# トレンドスコア計算（過去7日間の活動）
	def calculate_trending_score
		score = 0 
		score += daily_views * 0.5
		score += weekly_views * 0.3

		update(trending_score: score)
	end
end
