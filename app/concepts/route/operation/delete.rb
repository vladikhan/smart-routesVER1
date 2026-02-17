module Route::Operation
  class Delete < Trailblazer::Operation
    step :model!
    step :check_ownership!
    step :delete!

    def model!(ctx, params:, **)
      ctx[:model] = ::Route.find_by(id: params[:id])
    end

    def check_ownership!(ctx, current_user:, model:, **)
      # binding.pry
      puts "DEBUG: User ID: #{current_user&.id}, Route Owner ID: #{model&.user_id}"
      return false unless model && current_user
      model.user_id == current_user.id || current_user.is_admin?
    end

    def delete!(ctx, model:, **)
      model.destroy
    end
  end
end