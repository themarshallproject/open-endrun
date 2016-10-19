class Member < ActiveRecord::Base

	before_create :generate_token	

	serialize :visits_from_ips, JSON

	def active?
		self.active == true
	end

	def generate_token
		self.token = SecureRandom.urlsafe_base64
	end

	def update_stats(options={})
		ip = options['ip']
		self.last_ip = ip
		self.last_seen_at = Time.now

		self.visits_from_ips ||= {}
		self.visits_from_ips[ip] ||= 0
		self.visits_from_ips[ip] += 1
		
		save
	end

	def unique_ips
		(visits_from_ips || {}).keys.count
	end

	def total_views
		(visits_from_ips || {}).values.reduce(:+)
	end

	def update_stats_async(options={})
		MemberUpdateStats.perform_async(self.id, options)
	end
	
end