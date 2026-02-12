class Venue::Operation::DeletePhoto < Trailblazer::Operation
  step :model!
  step :delete_photo!

  def model!(ctx, params:, **)
    ctx[:model] = ::Venue.find_by(id: params[:id])
  end

  def delete_photo!(ctx, model:, params:, **)
    return false unless model

    attachment = model.photos.attachments.find_by(id: params[:photo_id])
    return false unless attachment

    attachment.purge
    true
  end
end

