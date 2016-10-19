class FacebookLinterWorker
  include Sidekiq::Worker

  def perform(post_id)
    linter = FacebookLinter.new(post_id: post_id)
    if linter.valid?
      result = linter.scrape
      puts "FacebookLinterWorker :: result=#{result.to_json}"
    else
      puts "FacebookLinterWorker :: invalid post_id=#{post_id}"
    end
  end
end