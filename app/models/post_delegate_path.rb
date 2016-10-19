class PostDelegatePath < ActiveRecord::Base
	
	belongs_to :post, touch: true
	validates :post, presence: true, uniqueness: true
	validates :path, length: { minimum: 2 }

	scope :active, -> { where(active: true) }

	def self.lookup_path(post_instance)
		self.active.find_by(post: post_instance).try(:path)		
	rescue
		puts "ERROR in PostDelegatePath.lookup_path: #{$!.inspect}"
		false
	end

end