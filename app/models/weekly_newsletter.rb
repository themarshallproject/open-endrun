class WeeklyNewsletter < ActiveRecord::Base

	has_many :weekly_newsletter_assignments
	
	scope :published, -> { where(public: true).where('published_at < ?', Time.now) }

	before_create do
		self.public = false
		self.published_at = Time.now + 30.minutes
	end

	after_create :create_mailchimp_campaign

	def state
		if    (self.public == true) and published_at > Time.now
			"Queued"
		elsif (self.public == true) and published_at <= Time.now
			"Live"
		elsif (self.public == false)
			"Private"
		else
			"Unknown"
		end
	end

	def sections 
		[]
	end

	def self.default_subject_line
		"Closing Argument"
	end

	def published?
		self.published.exists?(self)
	end

	def item_assignments
		WeeklyNewsletterAssignment
			.where(newsletter: self)
			.includes(:taggable)
			.order('position ASC, created_at DESC')
	end

	def attach_to(taggable)
		WeeklyNewsletterAssignment.where(taggable: taggable, weekly_newsletter: self).first_or_initialize
	end

	def remove_taggable(taggable)
		WeeklyNewsletterAssignment.where(taggable: taggable, weekly_newsletter: self).destroy_all
	end

	def self.most_recent
		WeeklyNewsletter.published.order('published_at DESC').first
	end

	def create_mailchimp_campaign
		CreateWeeklyNewsletterMailchimpCampaign.perform_async(self.id)		
	end

	def self.inject_styles(html)
		doc = Nokogiri::HTML(html)
		doc.css('a:not(.newsletter-button-link)').each do |a|
			a['style'] = "color: #ff0b3a;"
		end
		doc.css('blockquote').each do |el|
			el['style'] = [
				'font-size:22px;',
				'line-height:30px;',
				'margin: 0;',
				'margin-bottom: 30px;',
				'padding: 0;',
			].join(" ")
		end
		doc.css('span').each do |el|
			el['style'] = [
				'text-transform: uppercase;',
				'font-family: Courier;',
				'color: #ff0b3a;',
				'font-size: 13px;',
				'font-style: normal;',
			].join(" ")
		end

		# http://stackoverflow.com/questions/8512972/preventing-nokogiri-from-escaping-characters-in-urls for gsub
		doc.to_html.gsub('%7C','|')
	end

	def sync_to_mailchimp
		offline_renderer = OfflineTemplate.new.set_instance_vars(weekly_newsletter: self)
		
		builder_html = offline_renderer.render_to_string('weekly_newsletters/build', layout: false)		
		html =  WeeklyNewsletter.inject_styles(builder_html)

		text = offline_renderer.render_to_string('weekly_newsletters/build_text', layout: false).gsub('%7C','|')
		puts "syncing #{html} to #{self}"
		SyncWeeklyNewsletterMailchimpCampaign.perform_async(self.id, html, text)
	end

end
