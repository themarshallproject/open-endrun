xml.instruct!
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do

  xml.channel do
    xml.title 'The Marshall Project'
    xml.description "The Marshall Project is a nonprofit, nonpartisan news organization covering America's criminal justice system."
    xml.link root_url
    xml.language 'en'
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => "https://www.themarshallproject.org/rss/newsbank.rss"

    for post in @posts
      xml.item do
        xml.title post.title
        xml.subtitle post.deck
        xml.link post.canonical_url
        xml.category post.rubric.name
        xml.pubDate post.published_at.rfc2822
        xml.guid({:isPermaLink => "false"}, "post_id:#{post.id}")
        xml.description([
          PostRenderer.new(post).render(),
          "---",
          "Copyright The Marshall Project",
          "In the course of converting this article for NewsBank use, formatting and graphics may have been lost or distorted. To access the original article, visit #{post.canonical_url}?newsbank\n"
        ].join("\n"))
      end
    end

  end

end