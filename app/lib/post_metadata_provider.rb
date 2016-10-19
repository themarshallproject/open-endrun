class PostMetadataProvider

  attr_reader :post

  def initialize(post: nil)
    @post = post
  end

  def title
    post.title
  end

  def text_deck
    Nokogiri::HTML.fragment(post.deck).text.gsub("\n", " ").truncate(200).html_safe
  end

  def social_description
    text_deck
  end

  def display_headline
    cascade(post.display_headline, title)
  end

  def facebook_headline
    cascade(post.facebook_headline, title)
  end

  def facebook_description
    cascade(post.facebook_description, text_deck)
  end

  def twitter_headline
    cascade(post.facebook_headline, title)
  end

  def twitter_description
    cascade(post.facebook_description, text_deck)
  end

  def tweet_intent_headline
    escape cascade(post.twitter_headline, facebook_headline)
  end

  def og_facebook_photo_url
    photo_url = post.featured_photo.url_for(size: '1200x') rescue nil
    cascade(photo_url, "https://s3.amazonaws.com/tmp-uploads-1/social/mp-fb-og.png")
  end

  def og_twitter_photo_url
    photo_url = post.featured_photo.url_for(size: '1200x') rescue nil
    cascade(photo_url, "https://s3.amazonaws.com/tmp-uploads-1/social/mp-tw-og.png")
  end

  def produced_by
    ShortcodeAuthor.new.call(post.produced_by).html_safe
  rescue
    "<span style='display:none'>error in produced_by</span>".html_safe
  end

  # helpers

  def cascade(primary, secondary)
    if primary.present?
      return primary.to_s.html_safe
    elsif secondary.present?
      return secondary.to_s.html_safe
    else
      return ''
    end
  end

  def escape(uri_component)
    URI.escape(uri_component.to_str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

end
