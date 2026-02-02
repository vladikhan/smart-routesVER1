module Like::Operation
  class Delete < Trailblazer::Operation
    step :find_model!
    step :delete_with_counters!

    def find_model!(ctx, params:, current_user:, **)
      # Ищем лайк только среди лайков текущего юзера (безопасность!)
      ctx[:model] = current_user.likes.find_by(id: params[:id])
    end

    def delete_with_counters!(ctx, model:, **)
      Like.transaction do
        # Уменьшаем счетчик у родительского объекта
        target_klass = model.likeable_type.constantize
        if target_klass.column_names.include?("likes_count")
          target_klass.decrement_counter(:likes_count, model.likeable_id)
        end
        model.destroy
        
      end
    end
  end
end