class YahooPost < ActiveRecord::Base

	belongs_to :post
	validates :post, presence: true

	scope :published, -> { where(published: true) }

	def published?
		self.published == true
	end

	def lead_photo?
		# this is misnamed. it should be featured photo. the db col is lead_photo though. :(
		self.lead_photo == true
	end

	def title_with_fallback
		if title.present?
			title 
		else
			post.title		
		end
	end

end