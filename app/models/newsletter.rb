class Newsletter < ActiveRecord::Base

	has_many :newsletter_assignments

	scope :published, -> { where(public: true).where('published_at < ?', Time.now) }

	scope :stream, -> (min_time, max_time) do
		newsletter = published.order('published_at DESC').first
		if newsletter.nil?
			return []
		end

		if newsletter.published_at > min_time and newsletter.published_at < max_time
			[newsletter]
		else
			[]
		end
	end

	after_create :create_mailchimp_campaign

	before_create do
		self.public = false
		self.published_at = Time.now + 30.minutes
	end

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

	def to_param
		[id, email_subject.parameterize].join("-")
	end

	def self.default_subject_line
		"Opening Statement"
	end

	def sections
		[
			{
				slug: 'top_news',
				name: 'Pick of the News'
			}, {
				slug: 'nesw',
				name: 'N/S/E/W'
			}, {
				slug: 'commentary',
				name: 'Commentary'
			}, {
				slug: 'viral',
				name: 'Etc.'
			}
		].map{|section| Hashie::Mash.new(section) }
	end

	def published?
		Newsletter.published.exists?(self)
	end

	def items
		@items ||= NewsletterAssignment.where(newsletter: self).includes(:taggable).order('position ASC, created_at DESC').map{|assignment|
			taggable_attrs = assignment.taggable.attributes rescue {}
			{
				taggable: taggable_attrs.merge({
					html: nil,
					content: nil,
					model_name: assignment.taggable.class.name.downcase
				}),
				assignment: assignment.attributes
			}
		}.map{|_| Hashie::Mash.new(_) }
	end

	def item_assignments
		NewsletterAssignment.where(newsletter: self).includes(:taggable).order('position ASC, created_at DESC')
	end

	def homepage_items
		self.newsletter_assignments.order('homepage_position ASC').first(5)
	end

	def items_in_bucket(slug)
		self.items.select{|item| item[:assignment][:bucket] == slug }
	end

	def attach_to(taggable)
		NewsletterAssignment.where(taggable: taggable, newsletter: self).first_or_initialize
	end

	def remove_taggable(taggable)
		NewsletterAssignment.where(taggable: taggable, newsletter: self).destroy_all
	end

	def create_mailchimp_campaign
		CreateMailchimpCampaign.perform_async(self.id)
	end

	def mailchimp_web_url
		# will this always be us3? probably for our account? TODO
		"https://us3.admin.mailchimp.com/campaigns/wizard/confirm?id=#{self.mailchimp_web_id}"
	end

	def stream_sort_key
		published_at
	end

	def self.most_recent
		Newsletter.published.order('published_at DESC').first
	end

	def self.most_recent_archive_link
		self.most_recent.archive_url
	rescue
		"/?error-newsletter-archive-link"
	end

	def in_stream?
		true
	end

	def stream_promo_key
		"stream/newsletter"
	end

	def inject_utm(html)
		doc = Nokogiri::HTML.fragment(html)
		doc.css('a').each do |link|
			if link['href'].include?('themarshallproject.org')
				logger.info "Newsletter.inject_utm for link #{link['href']}"
				link['href'] = link['href'] + "?" + Post.new.social_query_params(utm_campaign: 'newsletter', utm_source: 'opening-statement', utm_medium: 'email', utm_term: "newsletter-#{self.created_at.strftime('%Y%m%d')}-#{self.id}")
			end
		end
		return doc.to_html
	end

	def self.is_tmp_story?(item)
		return true if item.model_name == 'post'

		return false if item.try(:url).to_s.include?('themarshallproject.org/documents') # blacklist DocCloud hosted docs. TK: a better solution
		return true  if item.try(:url).to_s.include?('themarshallproject.org')

		return false
	end

	def published_date_is_today?
		self.published_at.to_date == DateTime.now.to_date
	end

	def popular_tags(first: 5)
		links = NewsletterAssignment.where(newsletter: self).map(&:taggable)
		rollup = Tagging.where(taggable: links).select("tag_id, count(*) as tag_count").group_by("tag_id").order("tag_count desc")
		tag_ids = rollup.map{|i| i["tag_id"] }
		Tag.where(id: tag_ids)
	end

end
