class AdminApiV1Controller < ApplicationController

  before_action :verify_admin_api_key, except: [:serve_result, :preview_gist]
  before_action :verify_current_user_present, except: [:preview_post_via_post]

  skip_before_filter :verify_authenticity_token

  def preview_post_via_post
    @post = Post.new
    @post.title = params[:title] || "The test is here"    
    @post.rubric = Tag.find_by_name("News")
    @post.deck =  params[:title] || "The deck is the deck"    
    @post.post_format = params[:post_format] || "base"
    @post.byline_freeform = "First Last"

    @post.content = params[:content] || "no content found"
    puts "preview_post_via_post: #{@post.content}"

    html = render_to_string(layout: 'public', locals: { post_format: @post.post_format })
    uuid = SecureRandom.uuid
    
    Rails.cache.write("admin/v1/generated_page/#{uuid}", html, expires_in: 1.day)

    render text: "#{request.scheme}://#{request.host_with_port}/admin/preview/api/result/#{uuid}"	
  end

  def preview_gist
    gist_id = params[:gist_id]
    gist_url = "https://gist.github.com" + HTTParty.head("https://gist.github.com/#{gist_id}").headers['x-gist-url']
    gist_page = HTTParty.get(gist_url)
    doc = Nokogiri::HTML gist_page.body
    paths = doc.css('.raw-url').map{|el| el['href'] }
    assets = paths.inject({}){|obj, path| # parallel-ize?
      key = path.split("/").last
      obj[key] = HTTParty.get("https://gist.github.com"+path).body.force_encoding('UTF-8')
      obj
    }
    settings = YAML.load(assets['settings'])

    @debug = {assets: assets, settings: settings}

    @post = Post.new
    @post.id = -1
    @post.title = settings['headline']
    @post.rubric = Tag.find_by_name("News")
    @post.deck = settings['deck']  
    @post.custom_scss = assets['scss']
    @post.post_format = settings['post_format'] || "base"
    @post.byline_freeform = settings['byline'] || "First Last"
    @post.content = assets['content']

    render(layout: 'public', locals: { post_format: @post.post_format })
  end

  def serve_result
  	render html: Rails.cache.read("admin/v1/generated_page/#{params[:uuid]}")
  end

  private

  	def verify_admin_api_key
  		puts "request for #{params.inspect}"
  		unless ENV['ADMIN_V1_API_KEYS'].split(",").include?(params[:api_key])
  			render text: "invalid key, received: #{params.inspect}", status: 522
  			raise "oops"
  		end
  	end

end