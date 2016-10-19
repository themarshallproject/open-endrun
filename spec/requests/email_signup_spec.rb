require 'rails_helper'

RSpec.describe EmailSignup, type: :request do

  describe "api signup" do
    it "creates a signup with the v3 json api" do
      email = "signup#{SecureRandom.hex}@fake.com"

      request_params = {
        signup: {
          email: email,
          placement: 'the-placement',
          url: 'the-url',
          options: {
            daily: true,
            weekly: true,
            occasional: false,
          }
        }
      }

      Sidekiq::Testing.fake! do

        post '/api/v3/email/subscribe', request_params.to_json, { 'CONTENT_TYPE' => 'application/json' }

        signup = EmailSignup.find_by(email: email)
        expect(signup.email).to eq(email)
        expect(signup.signup_source).to eq('the-placement')
        expect(signup.confirm_token.length > 10).to be(true)
        expect(signup.options_on_create.to_json).to eq("{\"email\":\"#{email}\",\"placement\":\"the-placement\",\"url\":\"the-url\",\"options\":{\"daily\":true,\"weekly\":true,\"occasional\":false}}")

        expect(EmailSignupWorker.jobs.first['args']).to eq([signup.id])

      end

    end
  end

end
