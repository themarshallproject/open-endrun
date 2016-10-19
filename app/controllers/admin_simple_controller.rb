class AdminSimpleController < ApplicationController
	before_action :verify_current_user_present

	def edit
		PostLockSweeper.new.perform # sync! 

		@post = Post.find_by_id(params[:post_id])
		@post ||= Post.new

		if @post.persisted?
			@post_lock = PostLock.acquire(user: current_user, post: @post)
		end

	end
end
