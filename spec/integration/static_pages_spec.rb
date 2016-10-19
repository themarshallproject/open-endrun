require 'rails_helper'

describe 'static routes' do

	[
		"/",
		"/pixel.js",
		"/pixel/iframe",
		"/pixel/setup",
		"/donate",
		"/search",
		"/subscribe",
		"/subscribe/already-subscribed",
		"/subscribe/update-details/thank-you",
		"/about/privacy",
		"/api/v1/mailchimp-webhook"
	].each do |test_path|
		it "has a 200 status code for GET path=#{test_path} " do
			visit(test_path)
			expect(page.status_code).to eq 200
		end
	end

	it "has a 404 status code for /not-found" do
		visit("/not-found")
		expect(page.status_code).to eq(404) # important for the CDN to not cache these
	end

end
