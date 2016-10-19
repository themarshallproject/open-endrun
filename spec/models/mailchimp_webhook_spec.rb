require 'rails_helper'

RSpec.describe MailchimpWebhook, type: :model do
  it "creates an event correctly for a valid payload" do
    json = '{"type":"profile","fired_at":"2016-04-26 13:35:31","data":{"id":"11746a5205","email":"test@test.com","email_type":"html","ip_opt":"50.17.46.143","web_id":"174318697","merges":{"EMAIL":"test@test.com","FNAME":"John","LNAME":"Smith","MMERGE6":"","MMERGE9":"","MMERGE3":"","INTERESTS":"Opening Statement, Closing Argument","GROUPINGS":{"0":{"id":"12493","name":"Which emails would you like to receive?","groups":"Opening Statement, Closing Argument"},"1":{"id":"12713","name":"Interests","groups":""},"2":{"id":"12705","name":"Development","groups":"Individual funders"},"3":{"id":"12709","name":"Engagement","groups":""}}},"list_id":"5e02cdad9d"},"controller":"public","action":"api_v1_mailchimp_webhook"}'
    params = JSON.parse(json)

    expect {
      MailchimpWebhook.create_from_params(params)
    }.to change{
      MailchimpWebhook.where(event_type: 'profile', email: 'test@test.com').count
    }.by(1)

    webhook = MailchimpWebhook.where(event_type: 'profile', email: 'test@test.com').last
    expect(webhook.payload['type']).to eq 'profile'
    expect(webhook.payload['data']['email']).to eq 'test@test.com'
  end

  it "creates an event from a partial payload" do
    expect {
      MailchimpWebhook.create_from_params({})
    }.to change{
      MailchimpWebhook.count
    }.by(1)
  end

end
