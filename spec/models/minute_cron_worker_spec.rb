require 'rails_helper'

RSpec.describe MinuteCronWorker, type: :model do
  describe "#perform" do
    it "creates a new published_post_event entry for a new post" do
      ActionMailer::Base.deliveries.clear

      Sidekiq::Testing.inline! do

        post = create(:published_post)
        expect(PostPublishedEvent.where(post_id: post.id).count).to eq(0)
        expect(MinuteCronWorker.jobs.count).to eq(0)

        MinuteCronWorker.perform_async

        event = PostPublishedEvent.where(post_id: post.id)
        expect(event.count).to eq(1)
        expect(event.first.post_id).to eq(post.id)

      end
    end
    it "has the headline of the post in the email"
  end
end
