require 'rails_helper'

RSpec.describe PublicController, type: :request do

	describe "home page" do
		it "has a 200 status code" do
			get "/"
			expect(response.status).to eq(200)
		end
	end

	describe "email subscribe page" do
		it "has a 200 status code" do
			get '/subscribe'
			expect(response.status).to eq(200)
		end
	end

	describe "not found page" do
		it "has a 404 status code" do
			get '/not-found'
			expect(response.status).to eq(404)
		end
	end

	describe "post html partial" do
		it "can download the XHR for a published post" do
			post = create(:published_post)
			post.content = "contents of the post"
			post.save

			visit "/api/v1/post_html/#{post.id}"
			expect(page.body).to include post.rendered_content
			expect(page.body).to include post.title
		end

		it "cannot download the XHR for an unpublished post if not auth'd user" do
			post = create(:post)

			get "/api/v1/post_html/#{post.id}"
			expect(response.body).to eq "Not Found"
			expect(response.status).to be 404
		end
	end

	describe "Documents" do
		it "redirects to not-found for unknown Document slug" do
			get '/documents/undefined'
			expect(response).to redirect_to '/not-found?path=%2Fdocuments%2Fundefined'
		end
	end

	describe "Collections/Records" do
		it "redirects to not-found for unknown tag (collection) id" do
			get '/records/undefined'
			expect(response).to redirect_to '/not-found?path=%2Frecords%2Fundefined'
		end
	end


end
