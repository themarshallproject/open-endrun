require 'rails_helper'

RSpec.describe CreateMailchimpCampaign, type: :model do
  it "creates a campaign"
  # do
  #   ENV['MAILCHIMP_API_KEY'] = "test"
  #   newsletter = create(:newsletter)
  #   CreateMailchimpCampaign.new.perform newsletter.id
  #   expect(newsletter.mailchimp_id).to eq "x"
  # end

  it "raises an error if it cant find the newsletter" do
    expect {
      CreateMailchimpCampaign.new.perform(0)
    }.to raise_error ActiveRecord::RecordNotFound
  end

end
