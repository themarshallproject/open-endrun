require 'rails_helper'

describe 'public post', type: :integration do

	before :all do
		@published_post = create(:published_post)

		Newsletter.create!
		3.times.each do |_|
			Link.create!(url: 'http://nytimes.com', creator: User.create(email: SecureRandom.hex, password: SecureRandom.hex))
			create(:published_post)
		end

	end

	it 'has headline and content, no js', js: false do
		# TODO: get this working with JS on. some AJAX topshelf stuff breaking, i think.
		visit @published_post.path
		expect(page.html).to include(@published_post.title)
		expect(page.html).to include(@published_post.content)
	end

end
