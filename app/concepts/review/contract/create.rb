module Review::Contract
  class Base < Reform::Form
    property :text
    property :total_score

    validates :text, presence: true, length: { maximum: 1000 }
  end

  class Create < Base
    property :user_id
    property :reviewable_id
    property :reviewable_type

    validates :total_score, presence: true
    validates :user_id, presence: true
    validates :reviewable_id, presence: true
    validates :reviewable_type, presence: true
  end
end
