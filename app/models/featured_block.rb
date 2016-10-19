class FeaturedBlock < ActiveRecord::Base

    validates :template, length: { minimum: 2 }
    scope :published, -> { where(published: true).order('updated_at DESC') }
    serialize :slots, JSON

    # after_save :enforce_slot_count
    # def enforce_slot_count
    # 	dirty = false

    # 	self.slots = slots.select do |slot_id, config|
    # 		puts "loop #{slot_id} #{config}"
    # 		if slot_id.to_i > self.slot_count
    # 			dirty = true
    # 			puts "deleting #{slot_id}"
    # 			return false
    # 		end

    # 		return true
    # 	end

    # 	if dirty == true
    # 		self.save!
    # 	end
    # end

	def templates
		Hashie::Mash.new(YAML.load_file(File.join(Rails.root, 'config', 'featured_block_templates.yml')))
	end

	def valid_template?(template)
		templates.map{|k, _| k }.includes?(template)
	end

	def template_config
		templates[self.template]
	end

	def slot_count
		template_config.slots
	end

	def slot(index)
		self.slots.select{|k, _| k.to_i == index.to_i }.values.first rescue nil
	end

	def photo_for_slot?(index)
		slot(index)['show_image'] == 'true'
	end

	def post_ids
		(self.slots || []).map{|_, v| v['post_id'] }.compact
	end

	def posts
		@posts ||= Post.find(post_ids)
	end

	def post_for_slot(index)
		Post.find( slot(index)['post_id'] ) rescue nil
	end

	def published?
		self.published == true
	end

	def self.current_active
		FeaturedBlockActivateEvent.order('created_at DESC').first.featured_block rescue nil
	end

	def is_active?
		self == FeaturedBlock.current_active
	end

	def all_posts_published?
		self.posts.all? do |post|
			post.published?
		end
	rescue
		false
	end

	def dupe
		duped = FeaturedBlock.new
		duped = self.dup # http://stackoverflow.com/a/60053
		duped.published = false
		duped.save
		duped
	end

	def touch_if_contains_post(candidate_post_id)
		if self.post_ids.map(&:to_i).include?(candidate_post_id.to_i)
			logger.info "FeaturedBlock id=#{self.id}: touching because of #{candidate_post_id}"
			self.touch
		else
			logger.info "FeaturedBlock id=#{self.id}: not touching, don't have #{candidate_post_id}"
		end
	end

	def activate!(user)
		puts "featured_block#activate! #{self.id} by #{user.email} -- all_published? == #{self.all_posts_published?}"
		if self.all_posts_published?
			return FeaturedBlockActivateEvent.new(
				featured_block: self,
				user: user,
				snapshot: self.to_json
			).save
		else
			return false
		end
	end

end
