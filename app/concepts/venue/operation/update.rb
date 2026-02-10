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

  # def persist!(options, model:, params:, **)
  #   model.photos.attach(params[:venue][:photos]) if params[:venue][:photos].present?
  #   options['contract.default'].save
  # end
  # true
end
