class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    # 1. Пытаемся подтвердить пользователя по токену
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?

      # 3. Редиректим на страницу ввода кода
      redirect_to email_verification_path(confirmation_token: params[:confirmation_token])
    else
      # 4. Если токен протух или неверный — показываем ошибку
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  protected

  # Этот метод в данном случае не будет вызван, так как в show мы сделали ручной redirect_to.
  # Но на будущее (если захочешь вернуться к стандарту Devise) пусть лежит правильно.
  def after_confirmation_path_for(resource_name, resource)
    email_verification_path
  end
end
