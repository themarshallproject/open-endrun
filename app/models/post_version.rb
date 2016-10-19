class PostVersion < ActiveRecord::Base
	belongs_to :post
	serialize :content

	def as_post_mock
		post_mock = PostMock.new
		self.content.each do |k, v|
			puts "setting #{k} to #{v} in PostMock during PostVersion boot"
			post_mock.send("#{k}=", v)
		end
		post_mock
	end

	def diff_from_post
		live    = self.post.export
		version = self.as_post_mock.export
		Diffy::Diff.new(live.to_yaml, version.to_yaml).to_s(:html_simple)
	end

	def new_version_from_current
		PostVersion.create(
			post: self.post,
			content: self.as_post_mock.export
		)
	end

	def preview
		self.content.each do |k, v|
			puts "preview: #{k}= -> #{v}"
			self.post.send("#{k}=", v)
		end
		return self.post.changes
	end

	def publish!(user)
		raise "Must pass valid user to PostVersion publish" unless user.present? and user.can_publish?

		Post.transaction do
			self.content.each do |k, v|
				self.post.send("#{k}=", v)
			end
			puts self.post.changes
		end
	end

end