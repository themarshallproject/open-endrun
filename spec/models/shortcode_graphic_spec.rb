require 'rails_helper'

RSpec.describe ShortcodeGraphic, type: :model do

	it "extracts multiple graphic shortcodes correctly" do
		post = Post.create!(title: SecureRandom.hex, content: "content")
		graphic1 = Graphic.create!(html: "<div>some stuff</div>\n\n<figure>more things</figure>")
		graphic2 = Graphic.create!(html: "<script></script>")
		post.content = "here is some text\n\n[graphic id=#{graphic1.id}]\n\nand some more text\n\n[graphic id=#{graphic2.id}]\n\nend"
		expect(post.rendered_content).to eq("<p>here is some text</p>\n\n<div>some stuff</div>\n\n<figure>more things</figure>\n\n<p>and some more text</p>\n\n<script></script>\n\n<p>end</p>\n")
	end

	it "extracts a shortcode with single quotes on value" do
		post = Post.create!(title: SecureRandom.hex, content: "content")
		graphic = Graphic.create!(html: "<div>some stuff</div>\n\n<figure>more things</figure>")
		post.content = "here is some text\n\n[graphic id='#{graphic.id}']\n\nand some more text\n\n"
		expect(post.rendered_content).to eq("<p>here is some text</p>\n\n<div>some stuff</div>\n\n<figure>more things</figure>\n\n<p>and some more text</p>\n")
	end

	it "extracts a shortcode with double quotes on value" do
		post = Post.create!(title: SecureRandom.hex, content: "content")
		graphic = Graphic.create!(html: "<div>some stuff</div>\n\n<figure>more things</figure>")
		post.content = "here is some text\n\n[graphic id=\"#{graphic.id}\" label=\"whatever you want\"]\n\nand some more text\n\n"
		expect(post.rendered_content).to eq("<p>here is some text</p>\n\n<div>some stuff</div>\n\n<figure>more things</figure>\n\n<p>and some more text</p>\n")
	end

	it "fails gracefully for an invalid id" do
		post = Post.create!(title: SecureRandom.hex, content: "some text and a\n\n[graphic id=999] and more text")
		expect(post.rendered_content).to eq("<p>some text and a</p>\n\n<p><!-- graphic inject failed :: id=999 --> and more text</p>\n")
	end

end