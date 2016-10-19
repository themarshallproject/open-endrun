class ExternalServiceResponse < ActiveRecord::Base
	serialize :response, JSON

	after_create do 
		puts "ExternalServiceResponse:after_create #{self.inspect}"
	end

	def stale?
		self.created_at > 15.minutes.ago
	end

end
