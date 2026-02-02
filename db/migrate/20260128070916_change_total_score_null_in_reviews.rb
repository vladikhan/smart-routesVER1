class ChangeTotalScoreNullInReviews < ActiveRecord::Migration[6.1]
  def change
    change_column_null :reviews, :total_score, true
  end
end
