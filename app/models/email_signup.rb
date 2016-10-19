require 'mailchimp'
class EmailSignup < ActiveRecord::Base

	# https://bitbucket.org/mailchimp/mailchimp-api-ruby/src/fc745199610bc00ecb42388a241c8018e20cc4a1/lib/mailchimp/api.rb?at=master

	# regex? [\S]{1,}@[\S]{1,}\.[\S]{1,}

	serialize :options_on_create, JSON

	before_create do
		self.confirm_token = SecureRandom.urlsafe_base64
	end

	def self.to_csv(options={})
		emails_added = []
		CSV.generate(options) do |csv|
			csv << column_names
			self.order('created_at DESC').all.each do |record|
				if !emails_added.include?(record.email) and record.email.include?('@')
					emails_added << record.email
					csv << record.attributes.values_at(*column_names)
				end
			end
		end
	end

	after_create do
		EmailSignupWorker.perform_async(self.id)

		DebugEmailWorker.perform_async({
			from: 'ivong@themarshallproject.org',
			to: 'ivong+newsletteremailsignup@themarshallproject.org',
			subject: "[#{ENV['RACK_ENV']}] Email Signup",
			text_body: self.email
		})
	end

	def self.mailchimp
		Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
	end

	def self.merge_vars(list_id=ENV['MAILCHIMP_SUBSCRIBE_LIST_ID'])
		self.mailchimp.lists.merge_vars( list_id ) # production newsletter is "5e02cdad9d"
	end

	def self.all_lists
		self.mailchimp.lists.list()
	end

	def self.interest_groups(list_id=ENV['MAILCHIMP_SUBSCRIBE_LIST_ID'])
		self.mailchimp.lists.interest_groupings(list_id)
	end

	def db_to_mailchimp_merge_var(slug)
		({
			q_work_in_criminal_justice: "WORKSINCJ",
			q_is_journalist: "JOURNALIST",
			q_incarcerated: "PERSONAL",
			signup_source: "SIGNUP"
		})[slug]
	end

	def add_to_mailchimp
		# called with EmailSignupWorker

		# http://apidocs.mailchimp.com/api/2.0/lists/subscribe.php
		# groupings info:
		# as of Sept 2, 2015:
		#   "groups"=>
		#    [{"id"=>28853,
		#      "bit"=>"1",
		#      "name"=>"Opening Statement",
		#      "display_order"=>"1",
		#      "subscribers"=>nil},
		#     {"id"=>29557,
		#      "bit"=>"1024",
		#      "name"=>"Closing Argument",
		#      "display_order"=>"2",
		#      "subscribers"=>nil},
		#     {"id"=>28857,
		#      "bit"=>"2",
		#      "name"=>"Occasional Updates",
		#      "display_order"=>"3",
		#      "subscribers"=>nil}]},

		mailchimp_client = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
		result = mailchimp_client.lists.subscribe(
			ENV['MAILCHIMP_SUBSCRIBE_LIST_ID'],
			{ 'email' => email }, # email
			{ 'groupings' => [ # merge vars
				{
					'id' => 12493, # 12493 == "Which emails would you like to receive?"
					'groups' => initial_groupings()
				}
			]},
			'html', # email type
			false,  # false turns double_optin OFF
			true    # update existing?
		)

		self.mailchimp_euid = result["euid"]
		self.mailchimp_leid = result["leid"]
		self.save!

		return result
	end

	def initial_groupings
		daily      = options_on_create['options']['daily']      rescue true
		weekly     = options_on_create['options']['weekly']     rescue true
		occasional = options_on_create['options']['occasional'] rescue false

		groupings = []
		groupings << "Opening Statement"  if daily == true
		groupings << "Closing Argument"   if weekly == true
		groupings << "Occasional Updates" if occasional == true

		groupings
	end

	def build_merge_vars
		[ :q_work_in_criminal_justice,
		  :q_is_journalist,
		  :q_incarcerated,
		  :signup_source
		].inject({}){ |obj, item|
			obj[db_to_mailchimp_merge_var(item)] = self[item]
			obj
		}.select{ |k, v|
			v.present?
		}
	rescue
		puts "error in build_merge_vars: #{$!}"
		{}
	end

	def update_in_mailchimp

		# http://apidocs.mailchimp.com/api/2.0/lists/subscribe.php
		# https://gist.github.com/ivarvong/af7e9427b31d9a4e18d4

		merge_vars = build_merge_vars()
		puts "updating #{email} -- #{merge_vars}"

		mailchimp_client = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
		puts mailchimp_client.lists.subscribe(
			ENV['MAILCHIMP_SUBSCRIBE_LIST_ID'],
			{ 'email' => self.email }, # email
			merge_vars,   # merge vars
			'html',       	# email type
			false,  # false turns double_optin OFF
			true    # update existing?
		)
	end

	def self.all_segments(list_id=ENV['MAILCHIMP_SUBSCRIBE_LIST_ID'])
		self.mailchimp.lists.merge_vars([list_id])
	end

	def pull_mailchimp_member_info(list_id=ENV['MAILCHIMP_SUBSCRIBE_LIST_ID'])
		member_id = Digest::MD5.hexdigest(self.email.to_s.downcase)
		url = "https://us3.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}"
		puts url
		request = HTTParty.get(url, basic_auth: { username: 'endrun', password: ENV['MAILCHIMP_API_KEY'] })
		if request.code == 200
			data = JSON.parse(request.body).except('_links')
			self.mailchimp_data = data.to_json
			save!
		else
			puts "Error getting syncing data from Mailchimp for user #{self.email}"
		end
	end

	# def self.sync_from_bulk_export
	# 	mailchimp_export = MailchimpBulkExport.new.load_or_download
	# 	# emails = EmailSignup.all.load

	# 	self.all.each do |signup|

	# 		mailchimp_records = mailchimp_export.find_by_email(signup.email)

	# 		if mailchimp_records.first.present?
	# 			record = mailchimp_records.first
	# 			signup.mailchimp_is_active = true
	# 			signup.mailchimp_euid = record['EUID']
	# 			signup.mailchimp_leid = record['LEID']
	# 			signup.save
	# 		else
	# 			signup.mailchimp_is_active = false
	# 			signup.save
	# 		end
	# 	end
	# end

	# def self.export

	# 	email_signups = EmailSignup.all.to_a
	# 	export = MailchimpBulkExport.new.load_or_download

	# 	export.data.map{ |mailchimp_user|

	# 		email_signup = email_signups.select{|es| es.mailchimp_euid == mailchimp_user['EUID'] }.first

	# 		signup_location = email_signup.signup_source if email_signup.present?
	# 		signup_location ||= mailchimp_user["Signup Location"]

	# 		created_at = email_signup.created_at.strftime('%Y-%m-%d %H:%M:%S') if email_signup.present?
	# 		created_at ||= mailchimp_user["CONFIRM_TIME"]

	# 		# puts mailchimp_user

	# 		obj = ({
	# 			email: mailchimp_user["Email Address"],
	# 			created_at: created_at,
	# 			signup_location: signup_location,
	# 			member_rating: mailchimp_user["MEMBER_RATING"],
	# 			euid: mailchimp_user['EUID'],
	# 			endrun_id: email_signup.try(:id),
	# 		})

	# 		puts obj

	# 		obj.values.join("\t")
	# 	}.join("\n")

	# end

	# def self.export_to_file
	# 	path = File.join(Rails.root, 'data', 'email_signup_export.tsv')
	# 	File.open(path, 'w') do |f|
	# 		f.puts(self.export())
	# 	end
	# end

end
