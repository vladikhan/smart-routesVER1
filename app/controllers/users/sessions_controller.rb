class Users::SessionsController < SessionsController

	def create
		self.resource = warden.authenticate!(auth_options)

		#Check if email is confirmed
		unless resource.confirmed?
			#Store user id in session
			session[:pending_user_id] = resource.id

			#Send verification code
			resource.send_verification_code

			#Redirect to verification page
			redirect_to email_verification_path
			return
		end

		#If confirmed, sign in narmally
		set_flash_message!(:notice, :signed_in)
		sing_in(resource_name, resource)
		yield resource if block_given?
		respond_with resource, location: after_sing_in_path_for(resource)
	end
end