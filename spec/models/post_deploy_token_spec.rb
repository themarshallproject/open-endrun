require 'rails_helper'

RSpec.describe PostDeployToken, type: :model do
	
	before :all do
		@post = Post.create(title: "title", content: "I was set during before :all")
		@active_token   = PostDeployToken.create(post: @post, active: true)
		@inactive_token = PostDeployToken.create(post: @post, active: false)
	end
	
	it "should automatically create a token" do
		expect(@active_token.token.length > 10).to eq(true)
	end

	it "sets the `content` field for a valid token" do
		content = "Content updated in the test."

		err, value = PostDeployToken.update_post({ token: @active_token.token, content: content })
		expect(err).to eq(nil)

		@post.reload
		expect(@post.content).to eq(content)
	end

	it "doesn't work for invalid token" do
		content = "Content updated in the test."
		err, value = PostDeployToken.update_post({ token: "Bad Token", content: nil })
		expect(err).to_not eq(nil)

		@post.reload
		expect(@post.content).to_not eq(content)		
	end

	it "doesn't work for an inactive token" do
		content = "Content updated in the test."
		err, value = PostDeployToken.update_post({ token: @inactive_token.token, content: nil })
		expect(err).to_not eq(nil)

		@post.reload
		expect(@post.content).to_not eq(content)
	end

end