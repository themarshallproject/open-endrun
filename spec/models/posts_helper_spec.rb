require 'rails_helper'

RSpec.describe PostsHelper, type: :model do

	before :all do
		# make sure this matches the client-side generation
		@allowed_characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
	end

	describe "generating random social hash" do		
		it "has 11 characters" do 
			hash = PostsHelper.social_hash_id
			expect(hash.length).to eq(11)
		end
		it "begins with #." do
			hash = PostsHelper.social_hash_id
			expect(hash[0,2]).to eq('#.')
		end
		it "has 9 allowed chars" do
			1000.times.each do 
				hash = PostsHelper.social_hash_id
				hash.gsub('#.', '').split('').each do |letter|
					expect(@allowed_characters.include?(letter)).to eq(true)
				end
			end
		end
	end
end