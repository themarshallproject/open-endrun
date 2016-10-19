require 'rails_helper'

RSpec.describe "PostRenderer stress test" do

	before :all do
		@post_json_files = Dir.glob(File.join(Rails.root, "data", "posts", "*.json"))
	end

	it "has at least 400 json files for posts" do
		expect(@post_json_files.length > 400).to eq true
	end

	it "can render every post without error" do
		@post_json_files.each do |file|
			data = JSON.parse(File.open(file).read)
			post = Post.new({
				id: data['id'],
				title: data['title'],
				content: data['content']
			})
			expect(post.id > 0).to eq(true)
			expect(post.content.length > 0).to eq(true)
			expect(post.rendered_content.length > 10).to be true
		end
	end
end