class PostPublishedEvent < ActiveRecord::Base

  def perform!
    post = Post.find(self.post_id)

    Slack.perform_async('SLACK_DEV_LOGS_URL', {
      channel: "#digi",
      username: "PubPubPub",
      text: "#{post.title} <#{post.canonical_url}>",
      icon_emoji: ":inbox_tray:"
    })

    PostMailer.new_published(post).deliver_now
    FacebookLinterWorker.perform_async(post.id)
  end

end
