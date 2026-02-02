module Like::Contract
  class Create < Reform::Form
    property :user_id
    property :likeable_id
    property :likeable_type

    validates :user_id, :likeable_id, :likeable_type, presence: true
  end
end