module Api
class RegistrationsController < Devise::RegistrationsController	
	skip_before_action :verify_authenticity_token, raise: false

	  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /api/auth
	def create 
		build_resource(sign_up_params)

		if resource.save
			if resource.active_for_authentication?
				render json: {
					status: {
						code: 200,
						message: 'User registered successfully.'
					},
					data:resource.as_json(only: [:id, :username, :email])
				}, status: :created
			else
				render json: {
					status: {
					code: 200, message: 'User created. Waiting for activation.'
				}
			}, status: :ok
			end
		else
			render json: {
				status: {
					code: 422,
					message: 'User could not be created.',
					errors: resource.errors.full_messages
				}
			}, status: :unprocessable_entity
		end
	end

	 # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

	protected

	def sign_up_params
		params.require(:user).permit(:email, :password, :password_confirmation, :username, :bio, :location)
	end
	end
end