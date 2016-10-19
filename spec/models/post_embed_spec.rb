require 'rails_helper'

RSpec.describe PostEmbed, type: :model do
	it "is invalid without a post" do
		expect(PostEmbed.new(embed: Photo.new).valid?).to be(false)
	end
	it "is invalid without a embed" do
		expect(PostEmbed.new(post: Post.new).valid?).to be(false)
	end
	it "is valid with a post and a polymorphic embed" do
		expect(PostEmbed.new(post: Post.new, embed: Photo.new  ).valid?).to be(true)
		expect(PostEmbed.new(post: Post.new, embed: Graphic.new).valid?).to be(true)
	end
	
	it "creates a record when a [graphic] is in a post" do
		graphic = Graphic.create!(html: "graphic-content")
		post = Post.create!(title: "title", content: "graf\n\n[graphic id='#{graphic.id}']\n\ngraf2")

		rendered = post.rendered_content # first vs update, run rendered_content twice
		rendered = post.rendered_content
		expect(rendered).to eq("<p>graf</p>\n\ngraphic-content\n\n<p>graf2</p>\n")

		expect(PostEmbed.where(post: post, embed: graphic).count).to eq(1) # make sure we're not creating multiples

		embed = PostEmbed.where(post: post, embed: graphic).first
		expect(embed.updated_at > embed.created_at).to be(true) # make sure 'touch' works

		expect(PostEmbed.is_embedded(post: post, embed: graphic)).to eq(true)
		expect(PostEmbed.query_embeds(post: post)).to eq([graphic])
		expect(PostEmbed.query_posts(embed: graphic)).to eq([post])

		expect(PostEmbed.graphics).to eq([embed])
	end

	it "returns an empty array for a nil post" do
		expect(PostEmbed.query_embeds(post: nil)).to eq([])
	end

	it "creates a record when a [photo] is in a post"
	# do
	# 	photo = Photo.create!(original_url: "test-test-test")
	# 	post = Post.create!(title: "title", content: "graf\n\n[photo type=inline id=#{photo.id}]\n\ngraf2")
	# 	rendered = post.rendered_content
	# 	expect(rendered).to eq("<p>graf</p>\n\n                \n                    <div class=\"photo photo-inline-shim \" data-photo-config='{\"type\":\"inline\",\"id\":\"1\"}'>\n                    <div class=\"photo photo-inline \" data-photo-id=\"1\">\n                        <img data-src=\"\" onload='window.recordImageLoad(this);'>\n                        <div class=\"meta\">\n                        <span class=\"caption\"></span>\n                        <span class=\"byline\"></span>\n                        </div>\n                    </div>\n                    </div>\n                    \n\n<p>graf2</p>\n")

	# 	expect(PostEmbed.is_embedded(post: post, embed: photo)).to be(true)
	# end
end