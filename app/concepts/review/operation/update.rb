module Review::Operation
  class Update < Trailblazer::Operation
    step Model(Review, :find_by)
    step Contract::Build(constant: Review::Contract::Update)
    step Contract::Validate(key: :review) 
    step Contract::Persist()
    
    fail :log_errors!

    def log_errors!(options, **)
      if options['contract.default']
      end
    end
  end
end