class DmMessage::Contract::Create < Reform::Form
      property :message
      validates :message, presence: true, length: { maximum: 1000 }
end