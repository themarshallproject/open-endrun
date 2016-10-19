json.array!(@weekly_newsletters) do |weekly_newsletter|
  json.extract! weekly_newsletter, :id, :name, :email_subject, :mailchimp_id, :mailchimp_web_id, :byline, :published_at, :public, :archive_url, :opening_graf, :quote_graf
  json.url weekly_newsletter_url(weekly_newsletter, format: :json)
end
