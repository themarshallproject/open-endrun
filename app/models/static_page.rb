class StaticPage < ActiveRecord::Base
	validates :slug,      length: { minimum: 2 }
	validates :content,   length: { minimum: 2 }

	def to_param
		"#{id}-#{slug}"		
	end
end
