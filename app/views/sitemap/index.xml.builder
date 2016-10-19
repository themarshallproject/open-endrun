xml.instruct! :xml, :version => "1.0"
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  
  xml.url do
    xml.loc "https://www.themarshallproject.org"
    xml.lastmod FeaturedBlockActivateEvent.order('created_at DESC').first.created_at.to_date
    xml.changefreq "hourly"
    xml.priority "0.9"
  end

  for post in @posts do
    xml.url do
      xml.loc post.canonical_url
      xml.lastmod post.revised_at.to_date
      xml.changefreq "monthly"
      xml.priority "0.5"
    end
  end

end