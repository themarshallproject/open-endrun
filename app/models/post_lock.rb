class PostLock < ActiveRecord::Base
	
	belongs_to :post, touch: true
	belongs_to :user

	# after_create do
	# 	Slack.perform_async('SLACK_DEV_LOGS_URL', {
	# 		channel: "#production",
	# 		username: "PostLock",
	# 		text: "#{user.name} acquired lock for '#{post.title}'",
	# 		icon_emoji: ":fire:"
	# 	})
	# end
	# before_destroy :notify_destroy
	# def notify_destroy
	# 	Slack.perform_async('SLACK_DEV_LOGS_URL', {
	# 		channel: "#production",
	# 		username: "PostLock",
	# 		text: "Released lock for '#{post.title}' from #{user.name}",
	# 		icon_emoji: ":fire:"
	# 	})
	# rescue
	# 	logger.info "Error notifying deletion of PostLock #{id}"
	# end

	def self.current_locks
		self.all.map do |lock|
			user_name = lock.user.name rescue "id=#{lock.user_id}"
			{
				id: lock.id,
				post_id: lock.post_id,
				user_id: lock.user_id,
				user_name: user_name
			}
		end
	end

	def stale?
		# if the lock hasn't been touched in XX seconds, consider it ready garbage collection
		(Time.now - self.updated_at) > 30
	end

	def last_seen
		"#{(Time.now - self.updated_at).to_i}s"
	end

	def self.cleanup_stale_locks
		logger.info "PostLock starting cleanup_stale_locks"
		PostLock.all.each do |post_lock|
			
			if post_lock.post.nil?
				logger.info "PostLock cleanup_stale_locks: Post is nil, destroying #{post_lock.inspect}"
				post_lock.delete
			end

			if post_lock.stale?			
				logger.info "PostLock cleanup_stale_locks: Stale, deleting: #{post_lock.inspect}"	
				post_lock.destroy
			end
		end
	end

	def self.acquire(options={})
		user = options[:user]
		post = options[:post]

		lock = PostLock.where(post: post).first

		if lock.nil?
			logger.info "creating lock for #{post} for #{user}"
			return PostLock.create(user: user, post: post)
		end

		if lock.present? and lock.locked_by?(user)
			logger.info "already has a lock: #{post} by #{user}"
			return lock		
		end

		logger.info "failed to acquire lock for #{post} by #{user}"
		return false	
	end

	def self.release_all(options={})
		post = options[:post]
		PostLock.where(post: post).destroy_all
	end

	def locked_by?(candidate)
		candidate == self.user
	end

end