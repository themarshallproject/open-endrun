require 'rails_helper'

RSpec.describe QuizApiV1, type: :model do

	it "create_inline creates a record scoped by 'source'"
	#  do 
	# 	expect { 
	# 		QuizApiV1.create_inline(slug: SecureRandom.hex, content: '')
	# 	}.to change {
	# 		QuizApiV1.records.count
	# 	}.by 1
	# end

	it "ignores asset_files with a different 'source'" do 
		expect { 
			AssetFile.create!(slug: SecureRandom.hex, source: SecureRandom.hex)
		}.to change {
			QuizApiV1.records.count
		}.by(0)
	end


	it "retrieves the newest version of a slug"
	# do
	# 	slug = "slugtest"+SecureRandom.hex
	# 	v1 = QuizApiV1.create_inline(slug: slug, content: 'v1')
	# 	v2 = QuizApiV1.create_inline(slug: slug, content: 'v2')
	# 	newest_version = QuizApiV1.newest_version_for_slug(slug)
	# 	expect(newest_version).to eql v2
	# end
	
end