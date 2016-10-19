require 'mailchimp'

class MailchimpExport
	def self.campaigns
		mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
		# https://apidocs.mailchimp.com/api/2.0/campaigns/list.php
		return mailchimp.campaigns.list({}, 0, 1000)
	end

	def self.members(list_id: nil)
		dc = ENV['MAILCHIMP_API_KEY'].split('-').last
		url = "https://#{dc}.api.mailchimp.com/3.0/lists/#{list_id}/members"
		auth = {username: 'x', password: ENV['MAILCHIMP_API_KEY']}

		req = HTTParty.get(url, basic_auth: auth, query: {limit: 50000})
		JSON.parse(req.body)
	end

	def self.campaign_ids
		self.campaigns['data'].map{|campaign| campaign['id'] }
	end

	def self.subscriber_activity(campaign_id: nil)
		# https://apidocs.mailchimp.com/export/1.0/campaignsubscriberactivity.func.php

		dc = ENV['MAILCHIMP_API_KEY'].split('-').last
		url = "https://#{dc}.api.mailchimp.com/export/1.0/campaignSubscriberActivity/"

		req = HTTParty.post(url, body: {
			apikey: ENV['MAILCHIMP_API_KEY'],
			id: campaign_id,
			include_empty: false,			
		})

		streamed_json = req.body # "\n" separated JSON objects, see: https://apidocs.mailchimp.com/export/1.0/
		records = streamed_json.split("\n").map{|row| 
			JSON.parse(row) rescue { error: true }
		}

		puts "Parsed #{records.count} rows for campaign_id=#{campaign_id}"

		return {
			campaign_id: campaign_id,
			data: records
		}
	end

	def self.key_for_campaign(campaign_id)
		"mailchimp-subscriber-raw-v1/#{campaign_id}.json"
	end

	def self.persist_subscriber_activity(campaign_id: nil)
		raise "No campaign id" if campaign_id.nil?

		data = self.subscriber_activity(campaign_id: campaign_id)
		json = JSON.pretty_generate(data)
	
		url = S3SyncUpload.new.perform(
			access_key: ENV['S3_UPLOAD_ACCESS_KEY'],
			access_secret: ENV['S3_UPLOAD_SECRET_KEY'],			
			bucket: ENV['S3_UPLOAD_BUCKET'],
			key: self.key_for_campaign(campaign_id),
			contents: json,
			acl: 'private'
		)
		puts "Persisted key=#{self.key_for_campaign(campaign_id)}"
		return url
	end

	def self.cached_subscriber_activity(campaign_id: nil)
		JSON.parse(
			AWS::S3.new(access_key_id: ENV['S3_UPLOAD_ACCESS_KEY'], secret_access_key: ENV['S3_UPLOAD_SECRET_KEY'])
				.buckets[ENV['S3_UPLOAD_BUCKET']]
				.objects[key_for_campaign(campaign_id)]
				.read
		)
	rescue
		puts "Couldn't fetch #{campaign_id}"
		{}
	end

	def self.persist_all_campaigns
		self.campaign_ids().shuffle.each do |campaign_id|
			puts "[START] id=#{campaign_id}"
			self.persist_subscriber_activity(campaign_id: campaign_id)
			puts "[END] id=#{campaign_id}"
		end
	end

	def self.activity_to_csv(obj)
		campaign_id = obj['campaign_id']
		obj['data'].map{|row|
			(email, events), = row.to_a
			events.map{|event|
				[campaign_id, email, event['action'], event['timestamp'], event['url'], event['ip']].join(",")
			}
		}.flatten.join("\n")
	rescue
		puts "Couldn't parse #{obj}"
		''
	end

	def self.all_to_csv
		csv = campaign_ids.map{|campaign_id|
			puts "Rolling #{campaign_id}"
			activity = self.cached_subscriber_activity(campaign_id: campaign_id)
			self.activity_to_csv(activity)
		}.join("\n")

		File.open("rollup.csv", "w") do |f|
			f.puts "campaign_id,email,action,timestamp,url,ip\n"
			f.puts csv
		end
	end

end