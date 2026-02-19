class Venue::Operation::Update < Trailblazer::Operation
  step Model(::Venue, :find_by)
  step Contract::Build(constant: Venue::Contract::Update)
  step Contract::Validate(key: :venue)
  step Contract::Persist()
  step :add_photos!

  def add_photos!(ctx, model:, params:, **)
  return true unless params[:venue] && params[:venue][:photos].present?
  
  photos = Array(params[:venue][:photos]).reject(&:blank?)
  model.photos.attach(photos) if photos.any?
  true
  end
end
