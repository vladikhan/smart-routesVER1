class AvatarUploader < CarrierWave::Uploader::Base
	include CarrierWave::MiniMagick

	storage :file
	
	def store_dir
		"uploads/#{model.class.to_s.undescore}/#{mounted_as}/#{model.id}"
	end

	#Images versions
	version :thumb do
		process resize_to_fill: [100, 100]
	end

	version :medium do
		process resize_to_fill: [300, 300]
	end

	#Allowed formats
	def extension_allowlist
		%w[jpg jpeg gif png webp]
	end

	#Default file's name
	def default_url(*args)
		"/images/default_avatar.png"
	end
end