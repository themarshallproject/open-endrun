class Photo < ActiveRecord::Base

	validates :original_url, length: { minimum: 10 }

	def default_sizes
		[ { size: '1200x', crop: nil},
		  { size: '1140x', crop: nil},
		  { size: '740x',  crop: nil},
		  { size: '360x',  crop: nil} ]
	end

	before_create {
		self.random_slug = SecureRandom.hex(4)
	}

	after_create :make_default_sizes
	def make_default_sizes
		default_sizes.each{ |resize|
			
			PhotoResizer.perform_async(
				photo_id: self.id, 
				size: resize[:size], 
				crop: resize[:crop],
				resize_key: self.build_resize_key(size: resize[:size], crop: resize[:crop]),
				photo_original_url: self.original_url
			)
		}
	end

	after_save :touch_models

	def build_resize_key(options={size: '1140x', crop: nil})
		"photo/#{self.random_slug}/#{self.id}/#{options[:size]}/#{options[:crop]}"
	end

	def add_new_size(options={})
		self.sizes = (self.sizes || {}).merge({
			options[:resize_key] => options[:public_url]
		})
		save!
		self.touch_models # cache busting, yay
	end

	def url_for(options={size: '1140x', crop: nil})
		resize_key = build_resize_key(size: options[:size], crop: options[:crop])
		if self.sizes.present? and self.sizes[resize_key].present?			
			if ENV['S3_PHOTO_CDN'].present?
				return [ENV['S3_PHOTO_CDN'], resize_key].join('')
			else
				logger.info "ENV var S3_PHOTO_CDN is not set, returning S3 url for photo."
				return self.sizes[resize_key]
			end
		else
			puts "CUTTING NEW SIZE!"
			PhotoResizer.perform_async(
				photo_id: self.id, 
				size: options[:size], 
				crop: options[:crop],
				resize_key: self.build_resize_key(size: options[:size], crop: options[:crop]),
				photo_original_url: self.original_url
			)	
			return "" # show something stale while we work
		end		
	end

	def touch_models
		# super hack for now, TODO FIXME BLAH. this should be a foreign_key and such
		
		Post.where(lead_photo_id: self.id).each do |post|
			post.touch
		end
		Post.where(featured_photo_id: self.id).each do |post|
			post.touch
		end

		Link.where(fb_image_url: self.original_url).all.each{|link|
			link.touch
		}

		# other cache invalidation stuff/timestamp bumping?
	end

	def photo_inline_shortcode
		"[photo type=inline id=#{self.id}]"
	end

	def photo_full_shortcode
		"[photo id=#{self.id}]"
	end

end