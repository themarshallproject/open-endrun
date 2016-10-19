class FacebookInsights
  # https://developers.facebook.com/docs/graph-api/reference/page/insights/

  def page_id
    "x"
  end

  def url
    "https://graph.facebook.com/v2.5/#{page_id}"
  end

  def request(time_since: 1.week.ago, time_until: Time.now, metric: [], period: 'day')
    HTTParty.get(url, params: {
      since: time_since,
      until: time_until,
      metric: metric,
      period: period,
    })
  end

end