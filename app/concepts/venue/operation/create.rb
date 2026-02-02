class Venue::Operation::Create < Trailblazer::Operation
  step Model(Venue, :new)
  step :assign_defaults!
  step Contract::Build(constant: Venue::Contract::Create)
  step Contract::Validate(key: :venue)
  step Contract::Persist()

  def assign_defaults!(options, model:, **)
    model.view_count = 0
    model.save_count = 0
    model.popularity_score = 0.0
    model.reviews_count = 0
    model.likes_count = 0
    model.status = 'approved'
    true
  end
end
