class CollectionsController < ApplicationController
  layout 'public'

  def magic_preview_link
    cookies.signed['_recPrev01'] = 'fd2d681'
    puts "CollectionsController#magic_preview_link set_cookie"

    redirect_to collections_index_path
  end

  def live
    raise "unauthorized" unless current_user.present?

    @links = Link.where('created_at > ?', 3.days.ago).order('created_at DESC')
    @latest_link = @links.first
  end

  def index
    @inject_public_cache_control = true

    @popular_tags, @tag_cache = CollectionSummary.popular
    @recent_tags = CollectionRecentQuery.new.perform
  end

  def show
    @inject_public_cache_control = true

    @tag = Tag.find_by(id: params[:id])

    if @tag.nil?
      redirect_to not_found_path(path: request.path) and return false
    end

    if params[:id] != @tag.to_param
      redirect_to collections_show_path(@tag) and return false
    end

    if params.keys.include?('edit')
      redirect_to edit_tag_path(@tag, advanced: true) and return false
    end

    if params[:sort].present?
      @sort_order = params[:sort]
    else
      @sort_order = 'popular'
    end


    if @tag.featured_photo.present?
      url = @tag.featured_photo.url_for(size: '1200x') rescue '?'
      @header_inline_styles = "background-image: url(#{url});"
    else
      @overlay_inline_styles = "background-image: url('#{ActionController::Base.helpers.asset_path('collections-bg.png')}') !important;"
    end

    post_ids = Tagging.where(taggable_type: 'Post').where(tag_id: @tag.id).pluck(:taggable_id)
    @posts = Post.where(id: post_ids).order('revised_at DESC')

    if params.keys.include?('serverlinks')
      link_ids = Tagging.where(taggable_type: 'Link').where(tag_id: @tag.id).pluck(:taggable_id)
      @popular_links = Link.where(id: link_ids).where('facebook_count > 10').order('facebook_count DESC').first(6)
      @recent_links  = Link.where(id: link_ids).where('facebook_count >  0').order('created_at     DESC').first(6)
    else
      @popular_links = []
      @recent_links = []
    end

    # @popular_links = @tag.related_links.order('facebook_count DESC').where('facebook_count > 1').first(6)
    # @recent_links  = @tag.related_links.order('created_at DESC').where('facebook_count > 1').first(6)
  end

  def api_v1_index_tags
    @inject_public_cache_control = true

    if params[:slice] == 'popular'
      records = Tag.collection_index_popular
    elsif params[:slice] == 'recent'
      records = Tag.collection_index_recent
    else
      records = []
    end

    render json: {
      version: "0.1.0",
      records: records
    }
  end

  def api_v1_items
    @inject_public_cache_control = true

    tag_id = params[:tag_id].to_i
    page   = (params[:page] || 0).to_i
    slice  = params[:slice].to_s
    models = params[:models].to_s.split(",")

    collection_slice = CollectionSlice.new(tag_id: tag_id, models: models, slice: slice, page: page)

    build_status = collection_slice.request_rebuild

    items = collection_slice.result
    total_count = items.count
    total_pages = collection_slice.total_pages(total_count)

    render json: {
      build_status: build_status,
      has_zero_links: collection_slice.has_zero_links?,
      current_page: collection_slice.page,
      total_pages: total_pages,
      total_count: total_count,
      params: params.slice(:tag_id, :slice, :models, :page),
      tag: collection_slice.tag,
      items: items,
    }
  end

  def api_v1_all_tags
    @inject_public_cache_control = true

    render json: JSON.parse(CollectionSummary.json_collection_index_all)
  end

  def api_v1_search
    @inject_public_cache_control = true

    query = params[:query]

    results = ES.search_links(query: query, size: 10)

    scores = results['hits']['hits'].inject({}){ |obj, item|
      obj[item['_id'].to_i] = item['_score']
      obj
    }

    link_ids = results['hits']['hits'].map{|hit| hit['_id'].to_i }
    tag_counts = Tagging.top_tags_from_taggables(type: 'Link', ids: link_ids, limit: 10)
    tag_ids = tag_counts.map{|r| r[:tag_id] }

    tags = Tag
      .where(id: tag_ids)
      .without_types(['content_type', 'category'])
      .map{ |tag|
        tag.slice(:id, :name).merge({
          count: tag_counts.select{|t| t[:tag_id] == tag.id }.map{|t| t[:item_count] }.reduce(:+),
          path: "/records/#{tag.to_param}",
        })
      }.sort_by{ |tag|
        -tag[:count]
      }.first(5)

    tag_names = tags.map{|t| t['name'] }

    puts "collections#api_v1_search query='#{query}' user='#{current_user.try(:email)}' result_count='#{tags.count}' result_tags='#{tag_names.to_json}'"

    render json: {
      elasticsearch_ms: results['took'],
      query: query,
      tags: tags,
    }
  end

  def api_v1_report_link
    # POST, no cache
    link = Link.find_by(id: params[:link_id])
    tag = Tag.find_by(id: params[:tag_id])
    user_id = current_user.try(:id)

    url = params[:url]

    report = LinkReport.new(
      status:  'submitted',
      link_id: link.id,
      tag_id:  tag.id,
      user_id: user_id,
      url: url
    )

    if report.save
      render text: "OK"
    else
      render text: "ERROR", status: 500
    end

  end

end
