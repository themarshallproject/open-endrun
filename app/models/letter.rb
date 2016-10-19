class Letter < ActiveRecord::Base

	# validates :name,    length: { minimum: 0 }
	# validates :email,   length: { minimum: 0 }
	# validates :content, length: { minimum: 00 }
	# validates :is_anonymous, inclusion: { in: [true, false] }
	# not validated: mailing address, twitter are optional

	validates :status,    length: { minimum: 3 }

	belongs_to :post, touch: true

	scope :pending,    -> { where(status: 'pending')  }
	scope :approved,   -> { where(status: 'approved') }
	scope :rejected,   -> { where(status: 'rejected') }

	scope :visible,   -> { where(is_anonymous: false, status: 'approved').order('created_at DESC') }
	scope :published, -> { where(is_anonymous: false, status: 'approved', stream_promo: true) }

	scope :stream, -> (min_time, max_time) {
		published.where('created_at < ?', max_time)
			       .where('created_at > ?', min_time)
	}

	before_create {
		self.status = 'pending'
		self.stream_promo = false
		self.original_content = self.content
	}

	after_create {
		Slack.perform_async('SLACK_DEV_LOGS_URL', {
			channel: "#endrun",
			username: "Letters To The Editor",
			text: "A new letter was submitted! '#{self.original_content}'",
			icon_emoji: ":doughnut:"
		})

		email_body = "https://www.themarshallproject.org/admin/letters/#{self.to_param}\n\n\n\n-----------\n#{self.content}"
		DebugEmailWorker.perform_async({
			from: 'ivong@themarshallproject.org',
			to: ["bhickman@themarshallproject.org", "ivong@themarshallproject.org", "pburgos@themarshallproject.org"],
			subject: "New Letter To The Editor",
			text_body: email_body,
			html_body: email_body,
		})
	}

	def to_param
		[
			id,
			name.truncate(100).parameterize,
			"letter",
			excerpt.truncate(50, separator: ' ').parameterize
		].join("-")
	rescue
		id
	end

	def statuses
		['pending', 'approved', 'rejected']
	end

	def visible?
		(is_anonymous == false) and (status == 'approved')
	end

	def published?
		self.visible? and stream_promo == true
	end

	def in_stream?
		true
	end

	def adjacent
		if self.post.present?
			Letter.visible.where(post_id: self.post_id).reject{ |candidate|
				candidate.id == self.id
			}
		else
			[]
		end
	end

	def stream_sort_key
		created_at
	end

	def is_public=(status)
		if status == 'public'
			self.is_anonymous = false
		else
			self.is_anonymous = true
		end
	end

end
