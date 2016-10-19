class ProjectRouterController < ApplicationController

	before_filter :allow_iframe_requests, only: [:next_to_die_embed]
	before_filter :log_actions

	def log_actions
		puts "ProjectRouter action=#{params[:action]}"
	end

	def next_to_die
		@inject_public_cache_control = true
		rendered_html = ProjectNextToDie.new.render_html(fragment: params[:fragment])
		render html: rendered_html.html_safe
	end

	def next_to_die_embed
		@inject_public_cache_control = true
		rendered_html = ProjectNextToDie.new.render_embed_html(fragment: params[:fragment])
		render html: rendered_html.html_safe
	end

	def next_to_die_case
		@inject_public_cache_control = true
		rendered_html = ProjectNextToDie.new.render_case_html(state_slug: params[:state_slug], case_slug: params[:case_slug])
		render html: rendered_html.html_safe
	end

	def next_to_die_tktk_hotfix
		redirect_to "https://d2st6y5ftsu3rn.cloudfront.net/images/next-to-die-facebook.jpg"
	end

	def books
		@post = Post.published.find_by(slug: 'books')

		if @post.present?
			@inject_public_cache_control = true
			render 'public/post.html', layout: 'public'
		else
			render text: "Not Found", status: 404
		end
	end

	private

		def allow_iframe_requests
			response.headers.delete('X-Frame-Options')
		end

end
