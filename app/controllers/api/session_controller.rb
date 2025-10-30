class Api::SessionsController < Devise::SessionsController
	skip_before_action :verify_authencity_token

	# POST /api/auth/sign_in
	def create
			# 1. Находим пользователя по email (или другому полю аутентификации)
		self.resource
		# sign_in(resource_name, resource) # Не вызываем sign_in для stateless API (по умолчанию)
      
      # ВАЖНО: В реальной реализации JWT-аутентификации
      # здесь генерируется и возвращается JWT. 
      # Мы пока возвращаем только информацию о пользователе.
			render json: (
				status: {
					code: 200,
					message: 'サインインに成功しました。'
				},
				data: {
					user: resource.as_json(only: [:id, :username, :email]),
					access_token: 'YOUR_GENERATED_JWT_TOKEN_HERE',
					token_expires_at: 1.hour.from_now.to_i
				}
			), status: :ok
	end
rescue ActionController::ParameterMissing => each
	    # Обработка случая, когда параметры отсутствуют
	render json: {
		status: {
			code: 400,
			message: 'リクエスト本文にユーザーパラメータが不足しています。'
		}
	}, status: :bad_request
	rescue => e
	# Обработка сбоя аутентификации (неверный email/пароль)
		render json: {
			status: {
				code: 401,
				message: 'メールアドレスまたはパスワードが無効です。
.'
			}
		}, status: :unauthorized
end

# DELETE /api/auth/sign_out
def destroy
	# Для stateless API выход часто не требуется, 
  # но мы можем просто вернуть 200 OK.
	render json: {
		status: {
		code: 200,
		message: 'サインアウトに成功しました
'
		}
	}, status: :ok
end

protected

  # Определяет, какие параметры используются для аутентификации (Devise)
	def resource_params
		params.require(:user).permit(:email, :password)
	end

	# Необходим для Devise (в отличие от registrations, session params не называют sign_in_params)
	def auth_options
		{ scope: resource_name }
	end
end