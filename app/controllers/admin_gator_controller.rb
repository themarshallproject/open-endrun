class AdminGatorController < ApplicationController

	before_action      :verify_current_user_present
	# before_filter      :allow_iframe_requests,     only: [:iframe, :get]
	# skip_before_filter :verify_authenticity_token, only: [:index, :iframe, :get]
	# def allow_iframe_requests
	# 	response.headers.delete('X-Frame-Options')
	# end

	def index
		@js = Uglifier.compile File.read File.join(Rails.root, 'app', 'views', 'admin_gator', 'bookmarklet.js')
	end

	def iframe
		@url = params[:url]
		render layout: false
	end

	def get_link
		url = Link.get_canonical_url(params[:url])
		link = Link.where(url: url).first_or_initialize
		render json: link.serialize
	end

	def update_link
		link = params[:link]
		url = Link.get_canonical_url(link[:url])
		record = Link.where(url: url).first_or_initialize do |link|
			link.creator = current_user
		end
		record.update_attributes link.permit(:url, :title, :approved, :editors_pick, :domain)
		record.save!
		# record.tag_ids = link[:tag_ids] # this will only work with link model that has been persisted... should TODO FIXME on this so it flushes in sync
		record.send(:tag_ids=, link[:tag_ids], current_user)

		render json: record.serialize
	end

	def activity
		time_window = 2.days
		@items = Link.where('created_at > ?', time_window.ago) + Tagging.where('created_at > ?', time_window.ago).includes(:taggable)
		@items.sort_by! do |item|
			-item.created_at.utc.to_i
		end
	end

	def search_links
		query = params[:q] || ''

		@records = ES.search_links(query: query, size: 64)['hits']['hits'].map{ |hit|
			[hit['_id'], hit['_score']]
		}.map{|link_id, score|
			link = Link.find(link_id)
			link.attributes.slice('url', 'title', 'domain', 'id', 'fb_image_url', 'created_at').merge(score: score)
		}

		@records ||= []
	end

	def suggest
		query = params[:q] || ''

		link_ids = @records = ES.search_links(query: query)['hits']['hits'].map{ |hit| hit['_id'] }
		links = Link.where(id: link_ids).includes(:taggings)

		tag_ids = links.flat_map{|link| link.taggings.pluck(:tag_id) }
		tags = Tag.where(id: tag_ids.uniq)

		tag_freq = tag_ids.inject(Hash.new(0)){|obj, item|
			obj[item] += 1
			obj
		}.sort_by{ |k, v|
			-v
		}

		render json: tag_freq.map{|tag_id, count|
			tag = tags.find(tag_id)
			{
				id: tag.id,
				name: tag.name,
				count: count
			}
		}
	end

	#######
	# POST
	#######
	def tag_post_index
		@posts = Post.all.order('published_at DESC')
	end

	def post
		# form page
		@post = Post.find(params[:id])
	end
	def post_json
		@post = Post.find(params[:id])
		render json: {
			id: @post.id,
			tag_ids: @post.tags.map(&:id)
		}
	end
	def update_post
		@post = Post.find(params[:id])
		#@post.send(:tag_ids=, link[:tag_ids], current_user)
	end


end