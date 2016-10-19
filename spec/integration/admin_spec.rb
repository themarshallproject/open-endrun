require 'rails_helper'


RSpec.feature "Admin" do

	before :each do
		user = create(:user)
		visit "/login"
		fill_in :email, with: user.email
		fill_in :password, with: user.password
		click_button "Log In"
	end

	it "shows the admin dashboard", js: true do
		visit("/admin")
		expect(page.body).to have_content("Welcome to EndRun.")
	end

	it "shows the post dashboard", js: true do
		visit("/admin/posts")
		expect(page.body).to have_content("Posts") # tktk improve!
	end

	# it "renders all post partials", js: true do
	# 	# this is a bit agressive, probably. this page XHR's every post partial. slow.
	# 	visit("/admin/qa/all")
	# end

end
