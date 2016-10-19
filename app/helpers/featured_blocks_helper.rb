module FeaturedBlocksHelper
	def photo_for_slot(featured_block, index)
		if featured_block.photo_for_slot?(index)
			featured_block.post_for_slot(index).stream_promo_photo_url rescue ''
		else
			''
		end
	end

	def background_image_for_slot(featured_block, index)
		if featured_block.photo_for_slot?(index)
			"background-image: url('#{featured_block.post_for_slot(index).stream_promo_photo_url rescue nil}')"
		else
			" "
		end
	end

	def rubric_name(featured_block, index)
		featured_block.post_for_slot(index).rubric.name
	end

	def rubric_path(featured_block, index)
		rubric = featured_block.post_for_slot(index).rubric
		public_tag_path(rubric.slug)+"?hp" rescue '#'
	end

end
