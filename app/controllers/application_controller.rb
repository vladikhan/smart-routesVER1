class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?

	protected

	def configure_permitted_parameters
		#登録 parameters
		devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :bio, :location, :budget_min, :budget_max])
		#アカウント更新
		devise_parameter_sanitizer.permit(:aaccount_update, keys: [:username, :bio, :location, :budget_min, :budget_max])

	end
	
end
