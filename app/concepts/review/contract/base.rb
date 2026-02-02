module Review::Contract
  class Base < Reform::Form
    property :text
    property :total_score

    validates :text, presence: true, length: { maximum: 1000 }
  end
end
