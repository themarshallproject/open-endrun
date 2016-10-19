require 'rails_helper'

RSpec.describe PrintRenderer, type: :integration do

	it "passes a smoke test" do
		post = create(:published_post, published_at: Time.now)
		print_path = public_print_post_path(
			year:  post.published_at.strftime('%Y'),
			month: post.published_at.strftime('%m'),
			day:   post.published_at.strftime('%d'),
			slug:  post.slug,
		)

		visit(print_path)

		expect(page.driver.response.headers['X-Robots-Tag']).to eq("noindex")
		expect(page.body.include?("title")).to be true
		expect(page.body.include?("content")).to be true
	end

end
