require 'rails_helper'

RSpec.describe PostsController, type: :feature do

	before :each do
		@user = create(:user)
		@post = create(:post)

		visit "/login"
		fill_in :email, with: @user.email
		fill_in :password, with: @user.password
		click_button "Log In"
	end

	it 'can edit an existing post', js: true do
		visit edit_post_path(@post)

		new_title = "The New Title #{rand}"
		fill_in "post[title]", with: new_title
		click_button "Save"

		@post.reload

		expect(page.current_path).to eq(edit_post_path(@post))
		expect(@post.title).to eq(new_title)
	end

	it "redirects posts#show to admin_preview_post" do
		post = create(:post)
		visit post_path(post)
		expect(page.current_path).to eq(admin_preview_post_path(post))
	end

end