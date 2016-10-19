require 'rails_helper'

RSpec.describe Tag, type: :model do
	before do
		user = create(:user)
		@tags = [
			Tag.create!(name: "tag1", tag_type: 'topic'),
			Tag.create!(name: "tag2", tag_type: 'location'),
			Tag.create!(name: "tag3", tag_type: 'topic'),
			Tag.create!(name: "tag4", tag_type: 'location')
		]
		@tag_ids = @tags.map(&:id)

		@link = Link.create!(
			creator: user,
			url: "fakeURL",
			title: "fakeTitle",
			domain: "fakeDomain"
		)
	end

	it "adds via tag_ids=" do
		@link.tag_ids = @tag_ids
		expect(@link.tag_ids.sort).to eq(@tag_ids.sort)
	end

	it "is public when created" do
		tag = create(:tag)
		expect(tag.public).to be true
	end

	it "removes all tags for []" do
		@link.tag_ids = []
		expect(@link.tag_ids).to eq([])
	end

	it "intersects tag sets correctly" do
		first_set = @tags.map(&:id)
		second_set = @tags.first(2).map(&:id)
		puts "setting first set: #{first_set}"
		@link.tag_ids = first_set
	 	puts "#{@link.tag_ids}"
		puts "setting second set: #{second_set}"
		@link.tag_ids = second_set
		expect(@link.tag_ids = second_set)
	end

	it "async generates collection slices for itself" do
		tag = create(:tag)
		Sidekiq::Testing.fake! do
			expect {
  			tag.rebuild_collection_slices
			}.to change(CollectionSliceWorker.jobs, :size).by(2)
		end
	end

end
