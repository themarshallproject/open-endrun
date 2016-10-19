class PostShareable < ActiveRecord::Base
	belongs_to :post
	validates :post, presence: true

	validates_uniqueness_of :slug
	validates :slug, presence: true

	def serialize
		{
			slug: slug,
			photo_id: photo_id,
			facebook_headline: facebook_headline,
			facebook_description: facebook_description,
			twitter_headline: twitter_headline,
			url: post.canonical_url(share: slug),
			twitter_url: twitter_url()
		}
	end

	def photo_url
		Photo.find(self.photo_id).url_for(size: '1200x')
	rescue
		nil
	end

	def og_facebook_photo_url
		self.photo_url
	end

	def og_twitter_photo_url
		self.photo_url
	end

	def twitter_url
		url = post.canonical_url(share: slug) + "&" + post.social_query_params(utm_source: 'twitter',  utm_content: 'post-shareable')
		"https://twitter.com/intent/tweet?text=#{CGI::escape twitter_headline}&url=#{CGI::escape url}"
	end

end