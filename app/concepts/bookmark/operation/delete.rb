module Bookmark::Operation
  class Delete < Trailblazer::Operation
    step :find_model!
    step :delete!

    def find_model!(ctx, params:, current_user:, **)
      ctx[:model] = current_user.bookmarks.find_by(
        item_type: params[:item_type],
        item_id: params[:item_id]
      )
    end

    def delete!(ctx, model:, **)
      model.destroy
    end
  end
end