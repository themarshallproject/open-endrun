class RssController < ApplicationController
	layout false

	def home
		data = {
			request_ip: request.ip,
			request_remote_ip: request.remote_ip,
			referer:    (request.referer    || '').force_encoding("UTF-8"),
			user_agent: (request.user_agent || '').force_encoding("UTF-8"),
		}
		puts "rss#home data=#{data.to_json}"
		@posts = Post.published.where(in_stream: true).order('revised_at DESC').first(20)
	end

	def tag
		@tag = Tag.where(slug: params[:slug], public: true).first

		raise "Invalid tag" if @tag.nil?

		items = Tagging.where(tag: @tag).map{ |tagging|
			tagging.taggable
		}.select{ |item|
			item.published? rescue false # TODO probably a better way to do this
		}.sort_by{ |item|
			-1 * item.stream_sort_key.to_i # .stream_sort_key must be implementment by any stream-able model
		}

		@posts = items.select{ |item|
			item.is_a?(Post) # disable this to flow Links in too
		}
	end

	def newsbank
		# this is a contract w/ NewsBank, consider it API Stable (do not change/break/etc. Caroline worked on the partnership)
		request.session_options[:skip] = true
		response.headers['Cache-Control'] = "public, max-age=180"

		page = (params[:page] || 0).to_i
		items_per_page = 20

		@posts = Post.published
			.order('revised_at DESC')
			.offset(page*items_per_page)
			.first(items_per_page)
	end

	def yahoo
		# this is a contract w/ Yahoo, consider it API Stable (do not change/break/etc. Ruth worked on the partnership)
		request.session_options[:skip] = true
		response.headers['Cache-Control'] = "public, max-age=0"

		@yahoo_posts = YahooPost.published.order('updated_at DESC').first(20)
	end
end
