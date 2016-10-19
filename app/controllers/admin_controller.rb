class AdminController < ApplicationController
  include ActionView::Helpers::DateHelper

  before_action :verify_current_user_present, except: []
  protect_from_forgery except: []

  def index
    @js = Uglifier.compile File.read File.join(Rails.root, 'app', 'views', 'admin_gator', 'bookmarklet.js')
  end

  def posts_index
    PostLockSweeper.perform_async
    @post_locks = PostLock.current_locks

    @page = params[:page].to_i || 0
    per_page = 50

    query = Post.order('status ASC, revised_at DESC')
    if params[:all] == 't'
      @posts = query.all
    else
      @posts = query.limit(per_page).offset(@page*per_page)
    end
  end

  def posts_email_index
    @posts = Post.order('updated_at DESC').all
    @new_post = Post.new
  end

  def performance
  end

  def feedback
  end

  def users
  end

  def freeform_email_editor
  end
  def freeform_email
    post = Post.new(content: params[:markdown])
    @content = post.rendered_content

    pre_html = render_to_string(layout: false)
    html = Roadie::Document.new(pre_html).transform
    render plain: html
  end

  def links_recent
    render json: Link.where('created_at > ?', 2.weeks.ago).order('created_at DESC').pluck(:url)
  end

  def taggings
  	@taggings = Tagging.order('created_at DESC').all
  end

  def activity
    @feed = Tagging.order('created_at DESC').all + Tag.order('created_at DESC').all
  end

  def dragons
  end

  def sidekiq_ttin
    SendTTIN.perform_async
    render text: "OK"
  end

  def search_queries
    @queries = PublicSearchQuery.order('created_at DESC').all
  end

  def yahoo_renderer
    yahoo_post = YahooPost.find(params[:id])
    render html: YahooRenderer.new(
      Post.find(yahoo_post.post)
    ).render(), layout: false
  end

  def gutcheck_stream
    oldest_post = Post.published.order('published_at ASC').first

    @dateslugs = (oldest_post.published_at.to_date..Time.now.to_date).step(1).map do |day|
      day.strftime("%Y%m%d")
    end

  end

  def user_sessions_json
    num_hours = (params[:hours] || 24).to_i
    render json: UserSession.summary(num_hours)
  end

  def users_last_seen
    render json: User.all.map{ |user|
      {
        email: user.email,
        last_seen: user.last_seen,
        delta: ((Time.now.utc.to_i - user.last_seen.utc.to_i) rescue nil),
        time_ago_in_words: (time_ago_in_words(user.last_seen) rescue nil)
      }
    }.sort_by{|record|
      -1 * (record[:delta] || 1)
    }
  end

  def flushall_cache
    render plain: Rails.cache.clear
  end

  def cache_stats
    render json: (Rails.cache.stats rescue 'unsupported')
  end

  def feature_flags
    render json: FeatureFlag.all.inject({}){|obj, item|
      obj[item.key] = item.value
      obj
    }
  end

  def queue_time
    req_start_micros = request.env["HTTP_X_REQUEST_START"].to_i
    now_micros = Time.now.utc.to_f * 1_000

    render json: {
      x_request_start: req_start_micros,
      now: now_micros,
      delta: now_micros - req_start_micros,
      request_env: request.env.inject({}){|obj, (k, v)|
        obj[k.to_s] = v.to_s
        obj
      }
    }
  end

  def header_debug
    render text: {
      request: request,
      local_ip: `hostname -i`.strip
    }.inspect
  end

  def post_bench
    @post = Post.new(
      slug: 'test',
      post_format: 'shell',
      title: params[:title] || 'Keffiyeh bespoke crucifix, pug stumptown Thundercats asymmetrical flannel',
      content: "[ATTACH]",
      published_at: Time.now,
      revised_at: Time.now
    )
    render 'post_bench', layout: 'public'
  end

  def email_signups
    @days = (params[:days] || 3).to_i
    csv = ['time', 'email', 'placement', 'url'].join("\t") + "\n" + EmailSignup.where('created_at > ?', @days.days.ago).order('created_at DESC').all.map{|row|
      placement = (row['signup_source'] || row.options_on_create['placement']) rescue 'unknown'
      url = row.options_on_create['url'] rescue 'unknown'
      [
        row.created_at.strftime("%Y%m%d-%H%M"),
        row.email,
        placement,
        url,
      ].join("\t")
    }.join("\n")

    render plain: csv
  end

  def stream_preview
    @items = Stream.new.items
  end

  def preview_promo_lte
    @letter = Letter.find(params[:id])
    render layout: 'public'
  end
  def preview_letter_lte
    @letter = Letter.find(params[:id])
    render 'public/view_letter', layout: 'public'
  end

  # def mailchimp_lists
  #     mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
  #     render json: mailchimp.lists.list
  # end

  def ar_debug
    render json: {
      gc: GC.stat,
      rails_application_database_config: Rails.application.config.database_configuration[Rails.env],
      ar_base_configs: ActiveRecord::Base.configurations[Rails.env],
      pg_threadsafe: PG.threadsafe?
    }
  end

  def tag_leaderboard
    num_days = (params[:days] || 7).to_i
    @data = Tagging.where('created_at > ?', num_days.days.ago).inject({}){ |obj, tagging|
      obj[tagging.user_id] ||= 0
      obj[tagging.user_id] += 1
      obj
    }.sort_by{|_, count| -1*count}
    @users = User.find(@data.map{|user_id, _| user_id })
  end

  def api_v1_content_minutes
    num_days = (params[:days] || 7).to_i
    word_count = Post.published.where('published_at > ?', num_days.days.ago).map(&:word_count).reduce(:+)
    render json: {
       past_days: num_days,
       word_count: word_count,
       minutes: word_count/250.0
    }
  end

  # def email_content_domain_mappings
  #   email_contents = Link.pluck(:email_content).compact.map{|link|
  #     matches = /\[(.*?)\]\((.*?)\)/.match(link)
  #     name = $1
  #     url = $2
  #     domain = URI(url).host rescue '?'
  #     [domain, url, name]
  #   }

  #   rollup = email_contents.inject({}) do |obj, item|
  #     domain, url, name = item
  #     obj[domain] ||= {}

  #     if domain != name
  #       obj[domain][name] ||= 0
  #       obj[domain][name] += 1
  #     end

  #     obj
  #   end

  #   rollup = rollup.sort_by{ |domain, names|
  #     -1 * names.map{|name, count| count }.sum
  #   }

  #   rollup = rollup.select{ |domain, names|
  #     !domain.nil?
  #   }

  #   results = rollup.map{ |domain, names|
  #     [
  #       domain,
  #       names.map{|name, count| "#{name} (#{count})"}.join("\t")
  #     ].join("\t")
  #   }.join("\n")

  #   render plain: results
  # end

  def frequent_tags
    output = Tagging.pluck(:tag_id).inject({}) { |obj, item|
      obj[item] ||= 0
      obj[item] += 1
      obj
    }.sort_by{|k, v|
      -v
    }.first(150).map{ |tag_id, count|
      tag = Tag.find(tag_id)
      {
        tag: tag.name,
        count: count,
        type: tag.type.name
      }
    }

    if params.keys.include?('csv')
      render plain: "Tag Name\tCount\tType\n" + output.map{|item|
        [item[:tag], item[:count], item[:type]].join("\t")
      }.join("\n")
    else
      render json: output
    end
  end

  def inlined_photos
    post = Post.find(params[:id])
    @photo_ids = []
    post.content.gsub(/\[photo (.+?)\]/) do |capture|
        array_args = $1.squeeze(' ').split(' ')
        args = array_args.inject({}) { |obj, item|
          k, v = item.split('=')
          obj[k.to_sym] = v
          obj
        }
        @photo_ids << args[:id]
    end
    @photos = Photo.where(id: @photo_ids)
  end

  def ops_dynos
    @dynos = JSON.parse HTTParty.get("https://api.heroku.com/apps/endrun/dynos", headers: {
      "Accept" => "application/vnd.heroku+json; version=3",
      "Authorization" => "Bearer #{ENV['HEROKU_API_KEY']}"
    }).body
  end

  def ops_restart_dyno
    render plain: {
      requested_restart: params[:dyno_id],
      response: HTTParty.delete("https://api.heroku.com/apps/endrun/dynos/#{params[:dyno_id]}", headers: {
        "Accept" => "application/vnd.heroku+json; version=3",
        "Authorization" => "Bearer #{ENV['HEROKU_API_KEY']}"
      }).body
    }.to_json
  end

  def stream_main_debug
    @stream = Stream.new(min_time: 10.years.ago)
  end

  def thriller_social_snapshot
    urls = Post.published.all.map(&:canonical_url)
    render json: Thriller.new.social_snapshot(urls)
  end

  def every_link
    @posts = Post.published.order('published_at DESC').all
  end

  def tag_bot
    if params[:id].nil?
      post_id = Post.published.all.shuffle.first.id
      redirect_to admin_audit_tag_bot_path(post_id) and return false
    end
    @tags = Tag.all
    @post = Post.find(params[:id])
  end

  def preview_post_inject
    @post = Post.new
    @post.slug = "test-post"
    @post.title = "The test is here"
    @post.rubric = Tag.find_by_name("News")
    @post.deck = "The deck is the deck"
    @post.post_format = "base"
    @post.byline_freeform = "First Last"
    content = HTTParty.get(params[:url]).body rescue "error downloading #{params[:url]}"
    content = content.force_encoding('UTF-8')
    @post.content = content

    render(layout: 'public')
  end

  def sidekiq_stats
    sidekiq_stats = Sidekiq::Stats.new
    render json: {
      sidekiq: {
        processed:       sidekiq_stats.processed,
        failed:          sidekiq_stats.failed,
        # busy:            sidekiq_stats.workers_size,
        # processes:       sidekiq_stats.processes_size,
        enqueued:        sidekiq_stats.enqueued,
        scheduled:       sidekiq_stats.scheduled_size,
        retries:         sidekiq_stats.retry_size,
        dead:            sidekiq_stats.dead_size,
        # default_latency: sidekiq_stats.default_queue_latency
      }
    }
  end

  def static_201503_analytics
    render 'admin/static/201503-analytics', layout: false
  end

  def robot_weekly_link_social
    @links = Link
      .where('created_at > ?', 7.days.ago)
      .order('facebook_count DESC')
      .first(20)
      .select{|link| !link.facebook_count.nil? }
  end

  def check_pixel_embed
    url = params[:url]
    if url.present?
      html = HTTParty.get(url).body
      has_js_embed = html.include?()
    end
  end

  def story_list
    render plain: Post.published.order('published_at ASC').map{ |post|
      [post.published_at.strftime('%Y-%m-%d'), post.title, Nokogiri::HTML.fragment(post.byline).text.gsub("By", "").strip].join("\t")
    }.join("\n")
  end

  def debug_os_links
    @newsletter = Newsletter.published.last
    @assignments = @newsletter.item_assignments
  end

  def react_tag_test
    @item = Link.last
  end

  def sprout_links
    @days = (params[:days] || 7).to_i
    @posts = Post.where('published_at > ?', @days.days.ago).order('created_at DESC')
  end

  def outcome_tracker
    # embed
  end

  def donation_sources
    render plain: StripeCustomer.where.not(stripe_customer_id: nil).order('created_at DESC').map{ |sc|
      [sc.created_at, sc.stripe_customer_id, sc.inbound_source].join("\t")
    }.join("\n")
  end

  def style_guide
    render layout: 'public'
  end

  def branding
    render layout: 'public'
  end

  def audit_css
    # if params[:post_ids].present?
    #   @posts = Post.where(id: params[:post_ids].split(','))
    # else
    #   @posts = Post.published.order('published_at DESC').last(10)
    # end
  end

  def qa_all
    @post_ids = Post.published.order('published_at DESC').pluck(:id)
  end

  def email_signups_per_day
    render plain: "created_at,signup_count\n" + EmailSignup.pluck(:created_at).map{|t|
      t.strftime("%Y%m%d")
    }.inject(Hash.new(0)){|o, i|
      o[i] += 1
      o
    }.sort_by{|k, v|
      k.to_i
    }.map{|k, v|
      "#{k},#{v}"
    }.join("\n")
  end

  def email_signups_per_day_chart
  end

  def tag_post_index

    @user = User.find(params[:user_id]) if params[:user_id]
    @user ||= current_user

    if params.keys.include?('all-untagged')
      @posts = Post.order('published_at DESC').select{ |post|
        post.tags.count < 3
      }
    elsif params.keys.include?('all')
      @posts = Post.order('published_at DESC')
    else
      post_ids = UserPostAssignment.where(user: @user).pluck(:post_id)
      @posts = Post.where(id: post_ids).includes(:taggings).all
    end

  end

  def tag_post_show
    @post = Post.find(params[:post_id])
  end

  def tag_post_search
    @post = Post.find(params[:post_id])

    tag_ids = Tagging.where(taggable: @post).map(&:tag_id)
    @current_tags = Tag.where( id: tag_ids ).where.not(tag_type: 'category')

    @tags = ES.search_tags(params[:q])
    render layout: false
  end

  def tag_post_update
    @post = Post.find(params[:post_id])
    @tag = Tag.find(params[:tag_id])

    if @tag.tag_type == 'category'
      raise "tag_post_update trying to update a rubric, failing"
    end

    if params[:perform] == 'delete'
      render json: @tag.remove_from(@post)
    elsif params[:perform] == 'create'
      render json: @tag.attach_to(@post).save
    else
      render json: {
        error: "unknown op"
      }
    end

  end

  def post_delegate_paths
    render json: PostDelegatePath.all.map{ |delegate|
      {
        post: {
          id: delegate.post.id,
          title: delegate.post.title,
          status: delegate.post.status,
        },
        active: delegate.active,
        path: delegate.path
      }
    }
  end

  def tmp_file_count
    render json: {
      rel_tmp_count: `find ./tmp | wc -l`.strip.to_i,
      abs_tmp_count: `find  /tmp | wc -l`.strip.to_i,
    }
  end

  def weekly_gator_report
    render plain: GatorReport.weekly
  end

  def post_snapshot_v1
    post = Post.find(params[:post_id])
    t = post.updated_at.to_s(:db).gsub(" ", "-")
    filename = "P#{post.id}__#{t}.txt"
    data = [
      post.custom_scss,
      post.freeform_post_header,
      post.inject_html,
      post.content
    ].join("\n\n" + "-"*50 + "\n\n")
    send_data data, type: 'text/plain; charset=UTF-8;', disposition: 'attachment', filename: filename
  end

  def email_signup
    render layout: 'public'
  end

  def posts_csv
    render plain: AnalyticsPosts.new.cached_csv, content_type: 'text/csv'
  end

  def links_csv
    render plain: AnalyticsLinks.new.cached_csv, content_type: 'text/csv'
  end

  def posts_days_csv
    render plain: AnalyticsPostsPerDay.new.cached_csv, content_type: 'text/csv'
  end


  # upload to S3 with minimal headache
  def quick_s3_upload
  end
  def process_quick_s3_upload
    uploader = QuickS3Upload.new(
      name: params['name'],
      content_type: params['content_type'],
      contents: params['contents']
    )

    uploader.upload

    render plain: uploader.cdn_url
  end

  def quizbuilder_index
    @quizs = QuizApiV1.records.order('created_at DESC').all.group_by do |quiz|
      quiz.slug
    end
  end
  def quizbuilder_edit
    asset_file = AssetFile.find_by(id: params[:asset_file_id])
    @attrs = asset_file.attributes.merge({ public_url: asset_file.public_url }) rescue nil
    # this is the editor interface
  end

  def v1_api_quizbuilder_create
    # HTTP POST, used in
    slug = params[:slug].parameterize
    content = params[:content]
    quiz_asset = QuizApiV1.create_inline(slug: slug, content: content)
    render json: {
      asset_file_id: quiz_asset.id,
      slug: quiz_asset.slug,
      public_url: quiz_asset.public_url,
    }
  end

  def quizbuilder_preview
    asset_file = AssetFile.find(params[:asset_file_id])
    content = QuizApiV1.post_preview_content(asset_file.public_url)
    @post = Post.new(title: "Quizbuilder Preview", deck: "You’ll still need to copy out the embed code, in the other tab, into a real post.", byline_freeform: "By <span>The Marshall Project</span>", content: content, published_at: 1.hour.ago, revised_at: 1.hour.ago, updated_at: 1.hour.ago, post_format: 'base')
    render layout: 'public'
  end

  def google_forms_index
    if params[:url].present?
      xsl = Nokogiri::XSLT(File.read(File.join(Rails.root, "data", "pretty_print_v1.xsl")))
      html = HTTParty.get(params[:url].strip).body rescue ''
      pretty_html = xsl.apply_to(Nokogiri::HTML(html))
      form = Nokogiri::HTML(pretty_html).css('.ss-form')
      # form = Nokogiri::HTML(pretty_html).css('.freebirdFormviewerViewFormContentWrapper')
      @form_html = [
        '<div class="g-google-form-v1">',
        "<style>p:last-of-type:after{display:none;}</style>",
        form.to_html.encode!('UTF-8', invalid: :replace, replace: ''),
        '</div>'
      ].join("\n")
    end
  end

  def link_reports_tsv
    header = ["time", "link_id", "tag_id", "status", "user_id", "url"].join("\t")
    rows = LinkReport.order('created_at DESC').all.map{ |l|
      [
        l.created_at.utc.to_i,
        l.link_id,
        l.tag_id,
        l.status,
        l.user_id,
        l.url
      ].join("\t")
    }.join("\n")
    render plain: header + "\n" + rows
  end

  def email_signup_tsv
    headers = ['id', 'created_at', 'created_at_month', 'status', 'open_rate', 'click_rate', 'member_rating', 'placement', 'url', 'referrer', 'utpv'].join("\t")
    rows = EmailSignup.order('created_at DESC').all.map{|signup|
      data = JSON.parse(signup.mailchimp_data) rescue nil
      if data.present?

        source = signup.options_on_create['placement'] rescue signup.signup_source
        if source.blank?
          source = 'unknown'
        end

        [
          signup.id,
          signup.created_at.strftime("%Y-%m-%d"),
          signup.created_at.strftime("%Y-%m"),
          data['status'],
          data['stats']['avg_open_rate'].to_f,
          data['stats']['avg_click_rate'].to_f,
          data['member_rating'],
          (source),
          (signup.options_on_create['url'] rescue 'unknown'),
          (signup.options_on_create['referer'] rescue 'unknown'),
          (signup.options_on_create['_utpv'] rescue '')
        ].join("\t")
      end
    }.compact.join("\n")
    render plain: headers + "\n" + rows
  end

  def update_tag_facebook_count
    render json: Tag.find_by(id: params[:id])&.update_facebook_counts
  end

  def product
  end

end
