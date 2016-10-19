require 'rails_helper'

RSpec.describe Photo, type: :model do
	before :all do
		@photo = Photo.create!(original_url: 'http://fake')
	end

	it "has a random slug when created" do
		expect(@photo.random_slug.length).to eq(8)
	end
	
	it "builds a 1140px default photo resize key" do
		expect(@photo.build_resize_key).to eq("photo/#{@photo.random_slug}/#{@photo.id}/1140x/")
	end

	it "creates 4 sidekiq jobs for the default sizes" do
		Sidekiq::Testing.fake! do
			photo = Photo.create!(original_url: "http://fake2")
			expect(PhotoResizer.jobs.count).to eq(4)

			sizes = PhotoResizer.jobs.map{|job| job['args'] }.map{|arg| arg.first['size'] }
			expect(sizes).to eq(["1200x", "1140x", "740x", "360x"])
		end
	end

	it "returns a shortcode for type=inline" do
		expect(@photo.photo_inline_shortcode).to eq("[photo type=inline id=#{@photo.id}]")
	end

	it "returns a shortcode for no type (default full)" do
		expect(@photo.photo_full_shortcode).to eq("[photo id=#{@photo.id}]")
	end
end