module Bookmark::Operation
  class Create < Trailblazer::Operation
    step Model(Bookmark, :new)
    step :setup_params!
    step :persist!
    step :notify!

    def setup_params!(ctx, params:, current_user:, **)
      bookmark_params = params[:bookmark] || params

      ctx[:model].user = current_user
      ctx[:model].item_id = bookmark_params[:item_id]

      allowed_types = ['Route', 'Venue']
      input_type =bookmark_params[:item_type]

      if allowed_types.include?(input_type)
        ctx[:model].item_type = input_type
        ctx[:item] = ctx[:model].item
        true
      else
        ctx[:model].item_type = nil
        false
      end
    end

    def persist!(ctx, model:, **)
      model.save
    end

    def notify!(ctx, model:, **)
      content_owner_id = model.item&.user_id 
      return true unless content_owner_id && content_owner_id != model.user_id

      Notification::Operation::Create.call(params: {
        notification: {
          user_id:           content_owner_id,
          actor_id:          model.user_id,
          notification_type: 'bookmark', 
          notifiable:        model
        }
      })
      true
    end
  end
end