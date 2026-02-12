class Review::Operation::Create < Trailblazer::Operation
  # Добавляем уникальный id, чтобы избежать конфликтов
  step Model(::Review, :new), id: :build_model 
  step :setup_params!
  step Contract::Build(constant: Review::Contract::Create)
  step :authorize_not_banned!
  step Contract::Validate(key: :review)
  step Contract::Persist()
  step :attach_images!
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

  def setup_params!(ctx, params:, current_user:, reviewable: nil, **)
    return false unless current_user

    # Accept both controller-style params (`{ review: {...} }`) and operation-style flat params.
    incoming = params.is_a?(Hash) ? params : {}
    review_params =
      (incoming[:review] || incoming['review'] || {}).dup

    if review_params.empty?
      # Flat params (e.g. specs call with {reviewable_type, reviewable_id, text, total_score})
      review_params = incoming.slice(:text, :total_score, :reviewable_type, :reviewable_id)
      review_params = review_params.merge(incoming.slice('text', 'total_score', 'reviewable_type', 'reviewable_id'))
    end

    # Resolve reviewable either from explicit keyword or from params.
    if reviewable.nil?
      type = review_params[:reviewable_type] || review_params['reviewable_type']
      id = review_params[:reviewable_id] || review_params['reviewable_id']
      reviewable = type&.safe_constantize&.find_by(id: id)
    end

    review_params[:user_id] = current_user.id
    review_params[:reviewable_id] = reviewable&.id
    review_params[:reviewable_type] = reviewable&.class&.name

    ctx[:params] ||= {}
    ctx[:params][:review] = review_params
    ctx[:reviewable] = reviewable
    true
  end

  def authorize_not_banned!(ctx, current_user:, **)
    return true unless current_user.respond_to?(:is_banned) && current_user.is_banned

    ctx['contract.default']&.errors&.add(:base, 'アクセス権限がありません。')
    false
  end

  def notify!(options, model:, **)
  
    NotificationService.notify_review_added(model) if defined?(NotificationService)
    true
  end

  def attach_images!(ctx, model:, params:, **)
    incoming = params.is_a?(Hash) ? params : {}
    images = incoming[:images] || incoming['images'] || incoming.dig(:review, :images) || incoming.dig('review', 'images')
    return true if images.blank?

    Array(images).reject(&:blank?).each_with_index do |file, idx|
      review_image = model.review_images.build(position: idx + 1)
      review_image.image.attach(file)
      review_image.save!
    end

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