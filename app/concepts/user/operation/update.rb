module User::Operation
  class Update < Trailblazer::Operation
    step Model(User, :find_by)
    step Contract::Build(constant: User::Contract::Update)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :process_avatar_removal!

    def process_avatar_removal!(options, model:, params:, **)
      if params[:user] && params[:user][:remove_avatar] == "1"
        model.remove_avatar!
        model.avatar = nil
      end
      true 
    end
    
  end
end