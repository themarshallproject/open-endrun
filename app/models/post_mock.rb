class PostMock < Post
	
	before_create do
		raise "Can't persist a PostMock."
	end 

	before_save do 
		raise "Can't persist a PostMock."
	end

	attr_reader :authors, :rubric, :tags
	attr_accessor :post_id

	def author_ids=(author_ids)
		@authors = User.find(author_ids)
	end

	def rubric_id=(rubric_tag_id)
		@rubric = Tag.find(rubric_tag_id)
	end

	def tag_ids=(tag_ids)
		@tag_ids = Tag.find(tag_ids)
	end

end