class AddCountersToRoutes < ActiveRecord::Migration[6.1]
  def change
    # 1. Безопасно добавляем колонки
    add_column :routes, :likes_count, :integer, default: 0, null: false unless column_exists?(:routes, :likes_count)
    add_column :routes, :comments_count, :integer, default: 0, null: false unless column_exists?(:routes,
                                                                                                 :comments_count)
    add_column :routes, :reviews_count, :integer, default: 0, null: false unless column_exists?(:routes, :reviews_count)
    add_column :routes, :average_rating, :decimal, precision: 3, scale: 1, default: 0.0 unless column_exists?(:routes,
                                                                                                              :average_rating)

    # 2. Безопасно добавляем индексы
    add_index :routes, :likes_count unless index_exists?(:routes, :likes_count)
    add_index :routes, :average_rating unless index_exists?(:routes, :average_rating)

    # 3. Пересчитываем данные через SQL (безопасный метод)
    reversible do |dir|
      dir.up do
        say 'Updating counters for existing routes...'

        # Мы используем прямой SQL, чтобы не зависеть от связей в моделях
        execute <<-SQL
          UPDATE routes
          SET#{' '}
            likes_count = (SELECT count(*) FROM likes WHERE likes.likeable_id = routes.id AND likes.likeable_type = 'Route'),
            comments_count = (SELECT count(*) FROM comments WHERE comments.commentable_id = routes.id AND comments.commentable_type = 'Route'),
            reviews_count = (SELECT count(*) FROM reviews WHERE reviews.reviewable_id = routes.id AND reviews.reviewable_type = 'Route'),
            average_rating = COALESCE((SELECT ROUND(AVG(total_score), 1) FROM reviews WHERE reviews.reviewable_id = routes.id AND reviews.reviewable_type = 'Route'), 0.0)
        SQL
      end
    end
  end
end
