require 'report_v1'

class TagReportV1
	include Sidekiq::Worker
	
	def recent_user(link)
		begin
			link.taggings.order('created_at DESC').first.user.email.split('@').first
		rescue
			link.creator.email.split('@').first rescue '?'
		end
	end

	def perform(id)
		result = CSV.generate do |csv|
			csv << ["Created (UTC seconds)", "Link Title", "Tags", "User"]
			Link.order('created_at DESC').all.each do |link| 
				csv << [	
					link.created_at.utc.to_i,
					link.title, 
					link.taggings.map{|tagging| tagging.tag.name }.join(";"),
					recent_user(link)
				]
			end
		end

		ReportV1.fulfill_report(id, result)
		puts "Fulfilled report id=#{id}!"
	end
end