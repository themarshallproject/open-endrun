require 'rails_helper'

RSpec.describe LinksController, type: :request do

	# before :all do
	# 		@user = User.create!(email: "email_#{SecureRandom.hex}@themarshallproject.org", password: SecureRandom.hex)
	# 		@tag = Tag.create!(name: "tag_#{SecureRandom.hex}", tag_type: 'topic')

	# 		link1 = Link.create!(title: "link1", url: "http://fake1", creator: @user)
	# 		link2 = Link.create!(title: "link1", url: "http://fake2", creator: @user)
	# 		link3 = Link.create!(title: "link1", url: "http://fake3", creator: @user)
	# 		@tag.attach_to(link1).save
	# 		@tag.attach_to(link2).save
	# 		@tag.attach_to(link3).save

	# 		visit "/login"
	# 		fill_in :email,    with: @user.email
	# 		fill_in :password, with: @user.password
	# 		click_button "Log In"
	# end

	describe "#index" do
		it "has a valid response"
		# do
		# 	visit "/links"
		# 	expect(page.body).to include("0 link")
		# 	expect(response).to have_http_status(:success)
		# end
	end

end