module Review::Operation
  class Update < Trailblazer::Operation
    step Model(Review, :find_by)
    step Contract::Build(constant: Review::Contract::Update)
    step Contract::Validate(key: :review) 
    step Contract::Persist()
    
    fail :log_errors!

    def log_errors!(options, **)
      if options['contract.default']
        puts "Contract Errors: #{options['contract.default'].errors.full_messages}"
      end
      puts "Model Errors: #{options['model'].errors.full_messages}"
      puts "Params: #{options['params'].inspect}"
    end
  end
end