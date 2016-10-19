class GatorMailer < ApplicationMailer
	default from: 'ivong@themarshallproject.org'
	layout false

	def daily_email	
		@links = Link.where('created_at > ?', 24.hours.ago)
		mail(to: 'ivong@themarshallproject.org', subject: 'GatorToday', layout: false)
	end
end
