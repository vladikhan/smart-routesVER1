module User::Contract
  class Update < Reform::Form
    property :username
    property :bio
    property :avatar
    property :location
    property :remove_avatar
    
    validates :username, presence: true
    validates :bio, length: { maximum: 500 }
  end
end