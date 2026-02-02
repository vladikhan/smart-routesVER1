module Route::Operation
  class Update < Trailblazer::Operation
    step Model(::Route, :find_by)
    step Contract::Build(constant: Route::Contract::Update)
    step Contract::Validate(key: :route)
    step :persist_images!
    step Contract::Persist()

    def persist_images!(options, model:, params:, **)
      new_images = params[:route][:images]

      if new_images.present?
        images_to_add = Array(new_images).reject(&:blank?)

        model.images.attach(images_to_add) if images_to_add.any?
      end

      true
    end
  end
end
