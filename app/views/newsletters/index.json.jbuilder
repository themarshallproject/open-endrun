json.array!(@newsletters) do |newsletter|
  json.extract! newsletter, :id, :name, :email_subject, :mailchimp_id, :blurb, :template
  json.url newsletter_url(newsletter, format: :json)
end
