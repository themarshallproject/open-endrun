require 'rails_helper'

describe 'S3UploadForm' do
	before :all do 
		puts "building new form"
		@form = S3UploadForm.new(
			bucket:     'bucket',
			access_key: 'access',
			secret_key: 'secret',
			prefix: 'prefix'
		)
	end

	describe 'policy' do
		it 'expiration serializes' do
			expect(@form.expiration).to respond_to(:iso8601)
		end
		it 'has a policy' do
			expect(@form.policy).to respond_to(:to_s)
		end
	end
end