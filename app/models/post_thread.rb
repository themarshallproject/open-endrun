class PostThread < ActiveRecord::Base
	has_many :post_thread_assignments
	has_many :posts, through: :post_thread_assignments

end