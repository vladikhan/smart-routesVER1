class Review::Operation::Create < Trailblazer::Operation
  # Добавляем уникальный id, чтобы избежать конфликтов
  step Model(::Review, :new), id: :build_model 
  step :setup_params!
  step Contract::Build(constant: Review::Contract::Create)
  step Contract::Validate(key: :review)
  step Contract::Persist()
  step :notify!
  step :create_activity!
  step :update_ratings!

  def update_ratings!(ctx, model:, **)
    reviewable = model.reviewable
    all_reviews = reviewable.reviews

    return true unless all_reviews.any?

    avg = all_reviews.average(:total_score).to_f.round(1)
    reviewable.update_columns(average_rating: avg, reviews_count: all_reviews.count)
  end

  def setup_params!(options, params:, current_user:, reviewable:, **)
    
    review_params = params[:review] || {}
    
    review_params[:user_id] = current_user.id
    review_params[:reviewable_id] = reviewable.id
    review_params[:reviewable_type] = reviewable.class.name
    
    options[:params][:review] = review_params
    true
  end

  def notify!(options, model:, **)
    # Проверка: если сервис существует, вызываем его
    NotificationService.notify_review_added(model) if defined?(NotificationService)
    true
  end

  def create_activity!(ctx, model:, **)
    Activity.create!(
      user: model.user,
      trackable: model,
      key: "review.create"
    )
    true
  end
end