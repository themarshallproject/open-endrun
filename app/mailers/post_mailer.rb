class PostMailer < ApplicationMailer

	def new_published(post)
		@post = post

		to_list = ENV['POST_PUBLISHED_ALERT_EMAILS'].split(',')
		to_list << post.authors.map(&:email)
		to_list = to_list.flatten

		mail(to: to_list, subject: "#{@post.title} [PUBLISHED]")		
	end

end