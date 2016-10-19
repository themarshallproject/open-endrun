require 'rails_helper'

RSpec.describe FacebookCountWorker, type: :model do

	it "downloads a facebook count" do
		# this is a real story and a real facebook count
		# should this be mocked?
		url = "https://www.themarshallproject.org/2015/12/16/an-unbelievable-story-of-rape"
		expected_facebook_count = 5000

		user = User.create!(password: SecureRandom.hex)
		link = Link.create!(url: url, creator: user)
		FacebookCountWorker.new.perform(link.id)

		link.reload
		expect(link.facebook_count > expected_facebook_count).to be(true)
	end

end
