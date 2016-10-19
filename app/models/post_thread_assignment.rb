class PostThreadAssignment < ActiveRecord::Base

	belongs_to :post
	validates  :post, presence: true

	belongs_to :post_thread
	validates  :post_thread, presence: true

end