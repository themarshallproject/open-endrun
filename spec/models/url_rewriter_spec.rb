require 'rails_helper'

RSpec.describe URLRewriter, type: :model do

	it "has a default allowed_host for TMP" do
		expect(URLRewriter.new.allowed_host).to eq("www.themarshallproject.org")
	end

	it "should rewrite internal urls and maintain the hash if it already exists" do
		rewriter = URLRewriter.new(url: "https://www.themarshallproject.org/about#thehash")
		random_param = SecureRandom.hex
		params = { p1: :test1, p2: random_param }
		expect(rewriter.rewrite(params: params)).to eq("https://www.themarshallproject.org/about?p1=test1&p2=#{random_param}#thehash")
	end

	it "does not rewrite to the www subdomain" do
		original_url = "https://themarshallproject.org/about#thehash"
		rewriter = URLRewriter.new(url: original_url)
		random_param = SecureRandom.hex
		params = { p1: :test1, p2: random_param }
		expect(rewriter.rewrite(params: params)).to eq(original_url)
	end

	it "does not modify other hosts" do
		rewriter = URLRewriter.new(url: "http://nytimes.com/some-post/test")
		params = { p1: :test1, p2: :test2 }
		expect(rewriter.rewrite(params: params)).to eq("http://nytimes.com/some-post/test")
	end

	it "can rewrite for a custom host" do
		rewriter = URLRewriter.new(url: "http://nytimes.com/url#thehash", allowed_host: "nytimes.com")
		params = { p1: :test1, p2: :test2 }
		expect(rewriter.rewrite(params: params)).to eq("http://nytimes.com/url?p1=test1&p2=test2#thehash")
	end

	it "passes through nil urls" do		
		rewriter = URLRewriter.new(url: nil)
		expect(rewriter.rewrite(params: {a: :b})).to eq(nil)
	end

	it "can insert a hash if there is no hash" do
		rewriter = URLRewriter.new(url: "https://www.themarshallproject.org/about?oldparam=test")
		new_url = rewriter.rewrite(params: { a: 1, b: 7 }, optional_hash: "the-opt-hash")
		expect(new_url).to eq("https://www.themarshallproject.org/about?a=1&b=7#the-opt-hash")
	end

	it "does not overwrite an existing hash if optional_hash is passed" do
		rewriter = URLRewriter.new(url: "https://www.themarshallproject.org/about?oldparam=test#the-first-hash")
		new_url = rewriter.rewrite(params: { a: 1, b: 7 }, optional_hash: "the-second-hash")
		expect(new_url).to eq("https://www.themarshallproject.org/about?a=1&b=7#the-first-hash")
	end

end