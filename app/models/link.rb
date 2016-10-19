class Link < ActiveRecord::Base
  belongs_to :creator, class_name: 'User'
  validates_presence_of :creator

  validates :url,    length: { minimum: 5 }

  scope :published, -> { where(approved: true).order('created_at DESC') }

  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings, source: :taggable, source_type: 'Link'

  before_create {
    self.domain ||= url
    self.email_content = default_email_content()
    self.remote_is_alive = true
  }

  after_create {
    self.download
    self.notify

    (0..58).step(2).each{ |minute_increment|
      # every two minutes for the first hour
      FacebookCountWorker.perform_in(minute_increment.minutes, self.id)
    }

    (0..24).step(1).each{ |hour_increment|
      # every hour for the first day
      FacebookCountWorker.perform_in(hour_increment.hours, self.id)
    }

    (1..30).step(1).each{ |day_increment|
      # every day for the first month
      FacebookCountWorker.perform_in(day_increment.days, self.id)
    }

  }

  after_save {
    $stdout.puts("count#link.model-update=1")
  }

  def make_short_token()
    self.short_token = SecureRandom.hex
    self.save
  end

  def approved?
    self.approved == true or self.approved == nil
  end

  def valid_url?
    uri = URI.parse(self.url)
    uri.kind_of?(URI::HTTP)
  rescue
    false
  end

  def content_type
    content_type_tag_ids = Rails.cache.fetch("content_type_tag_ids", expires_in: 5.seconds, race_condition_ttl: 5.seconds) {
      Tag.where(tag_type: 'content_type').pluck(:id)
    }

    taggings.select{ |tagging|
      content_type_tag_ids.include?(tagging.tag_id)
    }.first.try(:tag)
  end

  def tag_ids
    taggings.pluck(:tag_id)
  end

  def tag_ids=(dest_tag_ids, user=nil)
    # used by gator to set tag_id array from client, react app
    dest_tags    = Tag.where(id: dest_tag_ids)
    current_tags = Tag.where(id: self.tag_ids)
    (dest_tags + current_tags).uniq.map do |tag|
      if dest_tags.include?(tag)
        tag.attach_to(self, user).save
      else
        tag.remove_from(self, user)
      end
    end
  end

  def tag_names
    Tag.where(id: tag_ids).pluck(:name)
  end

  def stream_sort_key
    created_at
  end

  def ratings
    # TODO: remove this?
  end

  def doc
    Nokogiri.HTML(self.html)
  end

  def display_title
    self.title
      .split(" - ").first
      .split(" | ").first
  rescue
    self.title
  end

  def serialize
    {
      id: self.try(:id),
      persisted: self.persisted?,
      title: self.try(:title),
      url: self.try(:url),
      tag_ids: self.try(:tag_ids),
      approved: self.try(:approved),
      editors_pick: self.try(:editors_pick),
      creator: self.try(:creator).try(:email)
    }
  end

  def display_source
    url_hammered = self.url.encode("UTF-8", invalid: :replace, replace: "")
    host = URI.parse(url_hammered).host
    host.gsub('www.', '')
    # matches = /(\w+)\.(\w+)\.(\w+)/.match(host)
    # if matches[2].present? and matches[3].present? # removes subdomains....
    #   "#{matches[2]}.#{matches[3]}"
    # else
    #   host
    # end
  rescue
    puts "display_source FAILED TO PARSE #{$!}"
    self.url
  end

  def og_title
    doc.css("meta[property='og:title']").first.attributes["content"].to_s rescue nil
  end
  def og_description
    doc.css("meta[property='og:description']").first.attributes["content"].to_s rescue nil
  end

  def og_image_url
    doc.css("meta[property='og:image']").first.attributes["content"].to_s rescue nil
  end

  def canonical_url
    doc.css("link[rel='canonical']").first.attributes["href"].to_s rescue nil
  end

  def og_description
    doc.css("meta[property='og:description']").first.attributes["content"].to_s rescue nil
  end

  def download
    LinkDownloadWorker.perform_async(self.id)
  end

  def update_og_image
    UploadLinkImage.perform_async(self.id)
  end

  def update_facebook_count
    FacebookCountWorker.perform_async(self.id)
  end

  def html
    html = Rails.cache.fetch("links:#{self.id}:#{self.updated_at.utc.to_i}:html", expires_in: 24.hours) {
      s3_download_time = Benchmark.ms do
        $stdout.puts("count#link.html.s3-cache-miss=1")
        @s3_response = HTTParty.get(self.html_url).body
      end
      $stdout.puts("measure#app.link.s3-download=#{s3_download_time}ms")
      @s3_response
    }

    $stdout.puts("count#link.html.fetched=1")
    html
  rescue
    puts "Link#html ERROR id='#{id}' url='#{self.html_url}' error='#{$!}'"
    ""
  end

  def photo
    if fb_image_url.present?
      @photo = Photo.find(self.photo_id) rescue nil
      if @photo.nil?
        puts "creating Photo object for link #{self.id}"
        @photo = Photo.create(original_url: fb_image_url, via_gator: true) # TODO: refactor
        self.photo_id = @photo.id
        self.save
      end
      @photo
    end
  end

  def default_email_content
    org = DomainToOrganization.lookup(self.domain)
    [
      self.title,
      "[#{org}](#{self.url})"
    ].join(" ")
  end

  def notify(options={})
    Slack.perform_async('SLACK_DEV_LOGS_URL', {
      channel: "#the-record",
      username: "The Recorder",
      text: "#{creator.email} created link: <#{self.url}|#{self.title}>",
      icon_emoji: ":crocodile:"
    })
  end

  def newsletters_appeared_in
    newsletter_ids = NewsletterAssignment.where(taggable: self).pluck(&:newsletter_id)
    Newsletter.where(id: newsletter_ids)
  end

  ## these are helpers for gator v2, but do not work on a link record instance.

  def self.get_canonical_url(url)
    url_hash = Digest::SHA256.hexdigest(url)
    cache_key = "links:raw_url:sha=#{url_hash}"
    response = Rails.cache.read(cache_key)
    if response.present?
      puts "returning cached version: #{url} => #{response}"
      return response
    else
      canonical_url = self.lookup_external_canonical(url)
      if canonical_url.present?
        puts "writing #{url} => #{canonical_url} to cache"
        Rails.cache.write(cache_key, canonical_url, expires_in: 1.day)
        return canonical_url
      else
        puts "couldnt find URL canonical version, returning original"
        url
      end
    end
  end

  def update_meta_tags!
    tag_array = doc().css('meta').map{ |el|
      Hash[el.to_a]
    }
    self.html_meta_json = JSON.generate(tag_array)
    self.save
  end

  def update_remote_status!
    req = HTTParty.get(self.url)
    if req.code == 200
      self.remote_is_alive = true
    else
      self.remote_is_alive = false
    end
    self.save
  end

  def lookup_meta(search_key, search_val, content_key)
    rows = JSON.parse(self.html_meta_json) rescue nil

    if rows.nil?
      LinkMetaTagWorker.perform_async(self.id)
      return nil
    end

    rows.select{ |candidate|
      candidate[search_key] == search_val
    }.first[content_key]
  rescue
    nil
  end

  def self.lookup_external_canonical(url)
    doc = Nokogiri::HTML(HTTParty.get(url, timeout: 10).body)

    link_canonical = self.get_head_uri(doc.css('link[rel="canonical"]'),   'href')
    fb_canonical   = self.get_head_uri(doc.css('meta[property="og:url"]'), 'content')

    puts "Link.lookup_external_canonical : " + {
      url: url,
      link_canonial: link_canonical,
      fb_canonical: fb_canonical
    }.to_json

    fb_canonical || link_canonical || url
  end

  def self.get_head_uri(node, selector)
    begin
      uri = URI.parse(node[0][selector])
      if uri.scheme.present? and uri.host.present?
        uri.to_s
      end
    rescue
    end
  end

end
