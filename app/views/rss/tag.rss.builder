xml.instruct!
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do

  xml.channel do
    xml.title "#{@tag.name} | The Marshall Project"
    xml.description "The Marshall Project is a nonprofit, nonpartisan news organization covering America's criminal justice system."
    xml.link public_tag_url(@tag.slug)
    xml.language 'en'
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => "https://www.themarshallproject.org/rss/tag/#{@tag.slug}.rss"

    for post in @posts
      xml.item do
        xml.title post.title
        xml.link post.canonical_url
        xml.pubDate post.published_at.rfc2822
        xml.guid post.canonical_url
        xml.description post.deck
      end
    end

  end

end