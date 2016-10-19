class PostEmbed < ActiveRecord::Base
	belongs_to :post, touch: true
	validates :post, presence: true

	belongs_to :embed, polymorphic: true
	validates :embed, presence: true

	def self.mark_embedded(post_id: nil, embed: nil)
		post = Post.find_by(id: post_id)

		if embed.nil? or post.nil?
			return false
		end

		record = self.where(post: post, embed: embed).first_or_create
		record.touch
	end

	def self.async_mark_embedded(post_id: nil, embed_type: nil, embed_id: nil)
		embed = embed_type.constantize.find(embed_id)
		self.mark_embedded(post_id: post_id, embed: embed)
	end

	def self.is_embedded(post: nil, embed: nil)
		self.find_by(post: post, embed: embed).present?
	end

	def self.query_embeds(post: nil)
		self.where(post: post).map(&:embed)
	end

	def self.query_posts(embed: nil)
		self.where(embed: embed).map(&:post)
	end

	def self.graphics
		self.where(embed_type: 'Graphic')
	end

	def self.photos
		self.where(embed_type: 'Photo')
	end

end
