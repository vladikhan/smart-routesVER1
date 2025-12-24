module Api
  class SessionsController < Devise::SessionsController
    # 1. Исправлена опечатка и добавлен raise: false для API
    skip_before_action :verify_authenticity_token, raise: false

    # POST /api/auth/sign_in
    def create
      begin
        # Пытаемся аутентифицировать пользователя стандартными средствами Devise
        self.resource = warden.authenticate!(auth_options)
        
        # 2. Исправлены круглые скобки () на фигурные {} в render json
        render json: {
          status: {
            code: 200,
            message: 'サインインに成功しました。'
          },
          data: {
            user: resource.as_json(only: [:id, :username, :email]),
            access_token: 'YOUR_GENERATED_JWT_TOKEN_HERE',
            token_expires_at: 1.hour.from_now.to_i
          }
        }, status: :ok

      rescue ActionController::ParameterMissing
        render json: {
          status: {
            code: 400,
            message: 'リクエスト本文にユーザーパラメータが不足しています。'
          }
        }, status: :bad_request

      rescue StandardError => e
        render json: {
          status: {
            code: 401,
            message: 'メールアドレスまたはパスワードが無効です。'
          }
        }, status: :unauthorized
      end
    end

    # DELETE /api/auth/sign_out
    def destroy
      render json: {
        status: {
          code: 200,
          message: 'サインアウトに成功しました'
        }
      }, status: :ok
    end

    protected

    def auth_options
      { scope: resource_name, recall: "#{controller_path}#new" }
    end
  end
end