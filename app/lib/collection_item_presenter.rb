class CollectionItemPresenter
  include ActionView::Helpers::TextHelper

  attr_reader :item

  def initialize(item)
    @item = item
  end

  def render
    if item.is_a? Link
      render_link
    elsif item.is_a? Post
      render_post
    else
      puts "CollectionItemPresenter got item=#{item.inspect}, returning {}"
      {}
    end
  end

  def render_link
    domain = URI.parse(item.url).host.to_s.gsub(/^www\./, '') rescue '?'
    photo_url = item.photo.url_for(size: '360x') rescue nil
    description = item.lookup_meta('property', 'og:description', 'content').to_s
      .gsub("&nbsp;", " ")
      .gsub("&#39;", "’")
      .gsub("&mdash;", "—")
    description = truncate(description, length: 150, seperator: " ", omission: ' ...') # why doesnt the seperator work here? TK

    publication = domain_to_organization(domain)

    {
      id: item.id,
      model: 'link',
      url: item.url,
      title: sanitize_title(item.title),
      description: description,
      photo_url: photo_url,
      has_photo: photo_url.present?,
      publication: publication,
      time: item.created_at.strftime("%m.%d.%Y"),
      facebook_count: item.facebook_count,
      utc_created_at: item.created_at.utc.to_i,
      no_photo: ActionController::Base.helpers.asset_path("collections-bg.png")
    }
  end

  def render_post
    photo_url = item.featured_photo.url_for(size: '360x') rescue nil
    rubric = item.rubric.name rescue ''
    {
      id: item.id,
      model: 'post',
      title: item.title,
      date: item.revised_at.strftime("%m.%d.%Y"),
      photo_url: photo_url,
      has_photo: photo_url.present?,
      deck: item.deck,
      rubric: rubric,
      path: "#{item.path}?ref=collections",
      no_photo: ActionController::Base.helpers.asset_path("collections-bg.png")
    }
  end

  def sanitize_title(dirty)
    dirty.to_s.gsub(/((\s+?)(-|--|\||\|\||::|:)(\s*?)(.+?))$/, '').strip
  end

  def domain_to_organization(domain)
    start_time = Time.now.utc.to_f
    contents = File.read(File.join(Rails.root, 'data', 'domain_to_organization.yml'))
    lookup = HashWithIndifferentAccess.new(YAML.load(contents))

    org = lookup[domain]

    # puts "domain_to_organization #{Time.now.utc.to_f-start_time}"

    if org.blank?
      return domain
    else
      return org
    end
  end

end
