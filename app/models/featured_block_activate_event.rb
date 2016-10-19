class FeaturedBlockActivateEvent < ActiveRecord::Base
	belongs_to :user
	belongs_to :featured_block
end
