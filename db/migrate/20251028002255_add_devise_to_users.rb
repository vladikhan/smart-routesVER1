class AddDeviseToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users do |t|
      # 1. Удаляем старый столбец пароля (если был password_digest)
      # Используем if_exists: true для безопасности
      t.remove :password_digest if column_exists?(:users, :password_digest)

      # 2. Добавляем поле Devise для пароля
      # * t.string :email, ... УДАЛЕНО, потому что оно уже есть в CreateUsers
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email 

    end

    # Индексы Devise
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true

    change_column_null :users, :email, false, ''
  end
end