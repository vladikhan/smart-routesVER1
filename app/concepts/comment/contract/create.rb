require "reform"
require "reform/form/dry"

module Comment::Contract
  class Create < Reform::Form
    include Dry 
    
    property :text
    property :commentable_id
    property :commentable_type
    property :parent_id
    property :user_id

    validation do
      required(:text).filled(min_size?: 1, max_size?: 1000)
      required(:commentable_id).filled
      required(:commentable_type).filled
      required(:user_id).filled
    end
  end
end