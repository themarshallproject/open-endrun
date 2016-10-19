class PostDeployToken < ActiveRecord::Base
	belongs_to :post

	scope :active, -> { where(active: true) }

	before_create do
		self.token = SecureRandom.urlsafe_base64
	end

	def self.update_post(params)		
		deploy_token = PostDeployToken.active.find_by(token: params[:token])
		post = deploy_token.try(:post)

		if deploy_token.nil? or post.nil?
			return ["Invalid Deploy Token", nil]
		end

		# if post.published?
		# 	return ["Cannot Update Published Post", nil]
		# end

		post.content = params[:content]

		if post.save
			Slack.perform_async('SLACK_DEV_LOGS_URL', {
		  		channel: "#endrun",
		  		username: "Deploy Token API",
		  		text: "Post updated: id=#{post.id} title='#{post.title}'",
		  		icon_emoji: ":sailboat:"
		  	})

			return [nil, "Updated Post id=#{post.id}"]
		else
			return ["Error Saving Post", nil]
		end
	end

end