require 'securerandom'

class ReportV1

	def self.generate_id
		SecureRandom.urlsafe_base64
	end	

	def self.fulfill_report(id, content)
		Rails.cache.write("report/v1/#{id}", content)		
	end

	def self.find_by_id(id)
		Rails.cache.read("report/v1/#{id}")
	end

end