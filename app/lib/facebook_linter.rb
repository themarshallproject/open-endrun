class FacebookLinter
  # https://stackoverflow.com/questions/12100574/is-there-an-api-to-force-facebook-to-scrape-a-page-again
  # big thanks to https://twitter.com/schwanksta for sending me this

  attr_reader :post

  def initialize(post_id: nil)
    @post = Post.published.find_by(id: post_id)
  end

  def valid?
    post.present?
  end

  def urls
    [
      post.canonical_url,
      post.canonical_url + "?utm_medium=social&utm_campaign=share-tools&utm_source=facebook&utm_content=post-top",
      post.canonical_url + "?utm_medium=social&utm_campaign=sprout&utm_source=facebook",
    ]
  end

  def scrape
    urls.map do |url|
      result = HTTParty.post("https://graph.facebook.com", query: {
        id: url,
        scrape: true,
        access_token: [ENV['FACEBOOK_CLIENT_ID'], ENV['FACEBOOK_CLIENT_SECRET']].join("|")
      })

      {
        url: url,
        result: result
      }
    end
  end

end