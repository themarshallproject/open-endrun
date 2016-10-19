class MailchimpWebhook < ActiveRecord::Base

  serialize :payload, JSON

  def self.create_from_params(_params)
    params = _params.except('controller', 'action')

    event_type = params['type'] rescue ''
    email      = params['data']['email'] rescue ''

    self.create(email: email, event_type: event_type, payload: params)
  end

end

