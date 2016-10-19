class PublicController < ApplicationController

  layout 'public'

  skip_before_filter :verify_authenticity_token, only: [:v2_email_subscribe, :v3_email_subscribe, :pixel_ping_js, :csp_report, :api_v1_mailchimp_webhook]

  def token_v2
    ensure_permanent_token()
    hash = SecureRandom.urlsafe_base64(20, false).gsub(/[_-]/, '').first(10) # only a-zA-Z0-9, remove _ and -

    cookie = cookies.signed[:t]

    first_seen = nil
    if cookie.present?
      first_seen = Time.now.utc.to_i - cookie.split('|').first.to_i
    end

    email_signup_id = cookies.signed[:_es_id]

    referer     = HammerString.coerce(request.referer)
    user_agent  = HammerString.coerce(request.user_agent)
    http_accept = HammerString.coerce request.env["HTTP_ACCEPT"]
    debug = {
      time: Time.now.utc.to_i,
      referer: referer,
      token: cookie,
      first_seen: first_seen,
      user_agent: user_agent,
      email_signup: email_signup_id,
      page_referer: HammerString.coerce(params[:referer]),
      http_accept: http_accept
    }
    logger.info "public#token_v2 #{debug.to_json}"

    render json: {
      csrf: form_authenticity_token().to_s,
      hash: hash,
    }
  end

  def whoami
    token = cookies.signed[:t]
    render json: {
      first_seen: (Time.at(token.split('|').first.to_i) rescue nil),
      has_email_signup: cookies.signed[:_es_id].present?
    }
  end

  def subscribe
    ensure_permanent_token()
    @ref = params[:ref]
  end

  def process_new_letter
    puts "create_letter: #{params}"
    puts "LTE public? params[:letter][:is_public] = #{params[:letter][:is_public]}"

    if params[:letter][:is_public].nil?
      params[:letter][:is_public] = false
    end

    letter_params = params[:letter].permit(:name, :email, :twitter, :street_address, :content, :post_id, :is_public)

    @letter = Letter.new(letter_params)
    @letter.status = 'pending'

    logger.info "test: #{params} produced object: #{@letter.inspect}"

    if @letter.save
      cookies.permanent.signed[:_lte] = @letter.id
      redirect_to '/submit-letter/thank-you'
    else
      redirect_to :back, notice: 'There was an error creating your letter.'
    end
  end

  def process_subscribe
    email = params['email']
    EmailSignupWorker.perform_async(email: email)
    redirect_to home_path
  end

  def process_email_details

    puts "process_email_details: #{params.inspect}"

    email_signup = EmailSignup.where(email: params[:email][:email], confirm_token: params[:email][:confirm]).first
    if email_signup.nil?
      redirect_to :back, error: "We encountered an error." and return false
    end

    params[:email].except(:email, :confirm).each do |key, val|
      email_signup[key] = val
    end

    email_signup.log_blob = params[:email].to_json

    if email_signup.save
      cookies.permanent.signed[:_es_id] = email_signup.id
      redirect_to email_details_thanks_path
    else
      render text: "error saving", status: 500
    end
  end

  def email_details_thanks
    # static
  end

  def v1_email_subscribe
    EmailSignup.where(email: params[:email].strip).first_or_create
    render plain: "Processing"
  end

  def v2_email_subscribe
    email = params[:email].strip
    email_signup = EmailSignup.where(email: email).first
    if email_signup.nil?
      options = {
        options: {
          daily: true,
          weekly: true,
          occasional: false
        },
        referer: HammerString.coerce(request.referer),
        user_agent: HammerString.coerce(request.user_agent),
      }
      email_signup = EmailSignup.new(email: email, signup_source: params[:ref])
      email_signup.options_on_create = options
      email_signup.save

      cookies.permanent.signed[:_es_id] = email_signup.id
      # .confirm_token is created in the before_create on the model, used now:
      redirect_to email_details_path(email: email, confirm: email_signup.confirm_token, ref: params[:ref])
    else
      redirect_to email_already_exists_path(email: email)
    end
  end

  def v3_email_subscribe
    # JSON endpoint

    puts "v3_email_subscribe: params=#{params.to_json}"

    email = params[:signup][:email].to_s.strip.downcase

    if email.blank?
      render status: 422, json: {
        status: "fail",
        error: {
          message: "No email address provided."
        }
      }
      return false
    end

    email_signup = EmailSignup.where(email: email).first

    if email_signup.present?
      render status: 422, json: {
        status: "fail",
        error: {
          code: "exists",
          message: "That email address already signed up."
        }
      }
      return false
    end

    # extract signup preferences, daily/weekly/occasional/etc, insert here:
    email_signup = EmailSignup.new(email: email)
    email_signup.options_on_create = params[:signup]
    email_signup.signup_source = params[:signup][:placement]

    if email_signup.save
      cookies.permanent.signed[:_es_id] = email_signup.id

      render json: {
        status: "ok",
        id: email_signup.id,
        confirm_token: email_signup.confirm_token, # .confirm_token is created in the before_create on the model, used now:
        redirect_url: email_details_path(email: email, confirm: email_signup.confirm_token, ref: params[:ref])
      }
    else
      render status: 500, json: {
        status: 'fail',
        error: {
          code: 'error',
          message: 'error saving new email'
        }
      }
    end

  end

  def email_details
    @email_signup = EmailSignup.where(email: params[:email], confirm_token: params[:confirm]).first
    if @email_signup.nil?
      render text: "Invalid email/confirm code!"
    end
  end

  def document
    @inject_public_cache_control = true
    @document = Document.resolve_slug(params[:dc_id])

    if @document.nil?
      redirect_to not_found_path(path: request.path) and return false
    end

    if @document.dc_id != params[:dc_id]
      redirect_to public_document_path(dc_id: @document.dc_id)
    end
  end

  def not_found
    render status: 404
  end

  def opening_statement_index
    raise "not allowed" unless current_user.present?
    @newsletters = Newsletter.published.order('published_at DESC') # TODO: paginate
  end

  def opening_statement
    raise "not allowed" unless current_user.present?
    @newsletter = Newsletter.find(params[:id])
  end

  def static_page
    @inject_public_cache_control = true

    slug = request.path.gsub('/', '')
    @page = StaticPage.where(slug: slug).first
    if @page.nil?
      redirect_to "/not-found?via=#{request.path}" and return false
    end
  end

  def author
    @inject_public_cache_control = true

    slug = params[:slug].downcase.gsub(/[\(\)]/, '') # downcase, replace common invalid url bugs like ( and )
    @user = User.where(slug: slug.downcase).first
    @stream = Stream.new(author: @user, infinity: false)

    if @user.nil?
      redirect_to not_found_path(path: request.path) and return false
    end
  end

  def submit_letter
    @post = Post.published.find(params[:post_id]) if params[:post_id].present?
    @letter = Letter.new(post: @post)
  end

  def tag_alias
    @inject_public_cache_control = true

    slug = request.path.gsub('/', '')
    @tag = Tag.where(slug: slug, public: true).first
    if @tag.nil?
      redirect_to "/not-found?via=#{request.path}" and return false
    end
    @stream = Stream.new(tag: @tag, infinity: false)
    render 'tag'
  end
  def tag
    @inject_public_cache_control = true

    @tag = Tag.where(slug: params[:slug], public: true).first
    if @tag.nil?
      redirect_to "/not-found?via=#{request.path}" and return false
    end
    @stream = Stream.new(tag: @tag, infinity: false)
  end

  def about_in_the_news
    @canonical_path = "/about/in-the-news"
    @tag = Tag.find_by(slug: 'in-the-news')
    @stream = Stream.new(tag: @tag, infinity: false)
    render 'tag'
  end

  def posts_tagged_by_slug
    @inject_public_cache_control = true

    tag = Tag.published.where(id: params[:id]).first
    if tag.nil?
      render text: "Not found", status: 404 and return false
    end

    render json: {
      tag: tag.slice(:id, :slug, :name, :updated_at),
      posts: tag.published_related_posts.map do |post|
        {
          id: post.id,
          published_at: post.published_at,
          title: post.title,
          url: post.canonical_url
        }
      end
    }
  end

  def view_letter
    @inject_public_cache_control = true
    @letter = Letter.visible.find(params[:letter_id]) # visible is a scope
  end

  def letters_index
    @inject_public_cache_control = true
    @letters = Letter.visible.all # visible is a scope
  end

  def user_public_key
    @user = User.where(slug: params[:slug]).first
    logger.info "public#user_public_key key download for #{@user.slug}"
    key_text = @user.public_key || "No public key for this person yet."
    send_data key_text, type: 'text/plain; charset=UTF-8;', disposition: 'attachment', filename: "#{@user.slug}.asc"
  end

  def home
    @inject_public_cache_control = true

    @featured_block = FeaturedBlock.current_active

    except_post_ids = @featured_block.post_ids rescue []

    if @featured_block.present? and @featured_block.template == 'one_one_kickstarter'
      puts "one_one_kickstarter LIVE" # TODO delete this whole thing
      except_post_ids = Post.published.order('revised_at DESC').pluck(:id).first(2)
    end
    @stream = Stream.new(except_posts: except_post_ids, infinity: false)

    # force HTML rendering, to get around HTTP_ACCEPT of "image/*", etc and the missing template problem.
    # http://stackoverflow.com/a/6778685
    render 'home.html'
  end

  def preview_home
    raise "not allowed" unless current_user.present?

    @featured_block = FeaturedBlock.current_active
    except_post_ids = @featured_block.post_ids rescue []
    @stream = Stream.new(except_posts: except_post_ids, infinity: false, show_newsletters: true)

    # force HTML rendering, to get around HTTP_ACCEPT of "image/*", etc and the missing template problem.
    # http://stackoverflow.com/a/6778685
    render 'home.html'
  end

  def post_html_partial_v1

    if current_user.present?
      @post = Post.find_by(id: params[:id]) # this includes unpublished posts, so we *must* have an auth'd user
    else
      @inject_public_cache_control = true
      @post = Post.published.find_by(id: params[:id])
    end

    if @post.nil?
      render plain: "Not Found", status: 404 and return false
    end

    if stale?(etag: @post, last_modified: @post.updated_at.utc)
      render partial: "public/posts/root", layout: false
    else
      puts "public#post_html_partial_v1 etag:304"
    end
  end

  def links
    render json: Link.published.limit(20).map{ |link|
      link.attributes.delete(:html, :approved)
      link
    }
  end

  def build_stream_partials
    {
      generated_at: Time.now.utc.to_i,
      min_time: @stream.min_time,
      max_time: @stream.max_time,
      items: @stream.items.map{ |item|
        {
          key: Stream.key(item),
          revised_at: (item.revised_at rescue nil), # some stream-able items don't use revised_at. Post does.
          html: render_to_string(partial: "public/stream/#{item.class.model_name.singular}", locals: { item: item })
        }
      }
    }
  end

  def stream_partials
    @inject_public_cache_control = true
    @stream = Stream.new(end_date: params[:end_date])
    render json: build_stream_partials()
  end

  def stream_topshelf
    @inject_public_cache_control = true
    render json: {
      v1: {
        records:          render_to_string(partial: "public/stream_topshelf/v1/records"),
        quickreads:       render_to_string(partial: "public/stream_topshelf/v1/quickreads"),
        facebook:         render_to_string(partial: "public/stream_topshelf/v1/facebook"),
        openingstatement: render_to_string(partial: "public/stream_topshelf/v1/openingstatement"),
      }
    }
  end

  def amp_post
    @post = Post.published.find_by(id: params[:id])
    if @post.present?
      render layout: false
    else
      render text: "Not Found", status: 404
    end
  end

  def post
    @inject_public_cache_control = true

    @post = Post.published.where(slug: params[:slug]).first

    if params.keys.include?('edit')
      redirect_to edit_post_path(@post) and return false
    end
    if params.keys.include?('epic')
        redirect_to edit_post_path(@post)+'?advanced' and return false
    end

    if @post.nil?
      redirected_post = Post.published.redirects(params[:slug]).first # cache this redirect?
      if redirected_post.present?
        logger.info "redirect post at:#{request.path} to post: #{redirected_post.path}"
        redirect_to redirected_post.path and return false
      else
        # log/notify 404? todo
        logger.info "redirect failed for:#{request.path}"
        redirect_to "/not-found?s=#{params[:slug]}" and return false
      end
    end

    puts "public#post path->post_id path=#{request.path} post_id=#{@post.id}"

    @stream = Stream.new(except_posts: [@post.id])

    response.headers['x-endrun-post-id'] = @post.id

    render 'post.html'

    # if stale?(etag: @post, last_modified: @post.updated_at.utc)
    #   # force HTML rendering, to get around HTTP_ACCEPT of "image/*"
    #   # and the (otherwise) missing template problem. http://stackoverflow.com/a/6778685
    #   render 'post.html'
    # else
    #   puts "public#post not-modified for #{request.path}, if-none-match:#{request.headers['if-none-match']}"
    # end

  end

  def print_post
    cookies.permanent[:_printed] ||= Time.now.utc.to_i

    # https://developers.google.com/webmasters/control-crawl-index/docs/robots_meta_tag#using-the-x-robots-tag-http-header
    # prevent Google/others from indexing the print page
    # the print page **does already** have a rel=canonical to the main page
    response.headers['X-Robots-Tag'] = 'noindex'

    @post = Post.published.where(slug: params[:slug]).first
    if @post.nil?
      logger.info "public#print_post could not find post, redirecting to '/'"
      redirect_to "/" and return
    end
  end

  def v1_published_urls
    urls = Post.published.order('published_at DESC').map(&:canonical_url)
    render json: {
      generated_at: Time.now.utc.to_i,
      url: urls
    }
  end

  def search_posts_api_v1
    client = ES.new
    results = client.search(params[:q])
    render json: results
  end

  def search_v1
    token = ensure_permanent_token() rescue "ERROR:MISSING_TOKEN"

    if params[:q].present?
      client = ES.new
      @search_results = client.search(params[:q])['hits']['hits'].map do |hit|
        {
          id: hit['_id'].to_i,
          score: hit['_score']
        }
      end
      post_ids = @search_results.map{|obj| obj[:id] }
      @posts = Post.published.where(id: post_ids).to_a.compact

      @sorted_results = @search_results.sort_by{|r|
        -1*r[:score]
      }

      user_id = current_user.try(:id)
      PublicSearchQuery.create(query: params[:q], token: token, referer: request.referer, search_results: @search_results.to_json, user_id: user_id)

    end
  end

  def pixel_ping_js
    response.headers['Cache-Control'] = "s-maxage=300, stale-while-revalidate=86400, stale-if-error=86400"
    request.session_options[:skip] = true
    render js: render_to_string('pixel_ping.js.erb', layout: false)
  end

  def pixel_ping_iframe
    render layout: false
  end

  def pixel_setup
  end

  def api_v2_decode
    data = TrackClick.decode(params[:token])
    ensure_permanent_token()

    if data.nil?
      puts "api_v2_decode INVALID_TOKEN=#{params[:token]}"
      redirect_to "https://www.themarshallproject.org?ref=invalid_decode_token" and return false
    end

    if data['source'].present?
      cookies.permanent.signed["c0:#{data['source']}"] = Time.now.utc.to_i
    end

    puts "api_v2_decode #{{ click: data, cookie: cookies }.to_json}"

    url = data['path'] || data['url']
    redirect_to url
  end

  def static_privacy
    @inject_public_cache_control = true
  end

  def static_marshall
    @inject_public_cache_control = true
    @post = Post.published.find_by(slug: 'about-thurgood-marshall')
    render 'post.html'
  end

  def csp_report
    puts "CSP_REPORT: #{request.body.read}"
    render text: "OK"
  end

  def pocket_confirm_domain
    render text: "pktPv304fc20bd28832d57edd57f4a37d075a8ab1fcacff81688605233e622c74e3e7"
  end

  def temp_admin_asset_rewrite
    # hack on June 22 to rewrite /admin/assets to /assets for Opening Statement assets
    # worth leaving this so the archive of that email keeps working
    redirect_to request.path.gsub(/^\/admin\/assets/, "/assets")
  end

  def external_preview
    @post = PublicPostPreview.post_from_token(params['token'])
    puts "public#external_preview post_id=#{@post.try(:id).to_json} current_user=#{current_user.try(:email).to_json} token=#{params['token']}"
    render 'post.html'
  end

  def api_v1_mailchimp_webhook
    MailchimpWebhook.create_from_params(params)
    render text: "OK"
  end

  def recognize_post_url_v1
    url = params[:url].to_s
    uri = URI.parse(url)
    routing = Rails.application.routes.recognize_path(uri.path)

    if routing[:controller] == 'public' and routing[:action] == 'post'
      post = Post.published.find_by(slug: routing[:slug])
      if post.present?
        render json: {
          id: post.id,
          title: post.title,
          path: post.path
        }
      else
        render status: 404, json: {
          message: "Not found"
        }
      end
    else
      render status: 500, json: {
        message: "This API is only for finding IDs for posts"
      }
    end

  end

end
