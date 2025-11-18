class AddVerificationCodeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :verification_code, :string
    add_column :users, :verification_code_sent_at, :datetime
    add_index :users, :verification_code
  end
end
