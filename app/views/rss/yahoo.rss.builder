xml.instruct!
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do

  xml.channel do
    xml.title 'The Marshall Project'
    xml.link root_url
    xml.description "The Marshall Project is a nonprofit, nonpartisan news organization covering America's criminal justice system."
    xml.language 'en'
    xml.copyright "Copyright The Marshall Project"
    xml.webMaster 'ivong@themarshallproject.org (Ivar Vong)'
    xml.generator "EndRun"
    
    for yahoo_post in @yahoo_posts
      post = yahoo_post.post
      html = YahooRenderer.new(post).render()
      xml.item do
        xml.guid({:isPermaLink => "false"}, "p#{post.id}")
        xml.title yahoo_post.title_with_fallback
        xml.link post.canonical_url
        xml.pubDate post.published_at.rfc2822

        if yahoo_post.lead_photo? and yahoo_post.post.featured_photo.present?
          photo = yahoo_post.post.featured_photo
          xml.enclosure(url: photo.url_for(size: '1140x'), type: 'image/jpeg') do
            xml.caption do 
              xml.cdata!(photo.caption)
            end
            xml.credits do
              xml.cdata!(photo.byline)
            end
          end
        end

        xml.description do
          xml.cdata!(html)
        end
       
      end
    end

  end

end