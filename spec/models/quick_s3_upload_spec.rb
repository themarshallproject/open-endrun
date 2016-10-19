require "rails_helper"

RSpec.describe QuickS3Upload, type: :model do

	describe "a new upload" do
		it "calculates the sha2" do
			contents = "this is test!"
			upload = QuickS3Upload.new(contents: contents, content_type: "n/a", name: "n/a")
			expect(upload.sha2_contents).to eq(Digest::SHA256.hexdigest(contents))
		end
		it "fixes names" do
			upload = QuickS3Upload.new(contents: "n/a", content_type: "n/a", name: "This!!! Is! Fun.csv")
			expect(upload.name).to eq("This-Is-Fun.csv")
		end
	end

end