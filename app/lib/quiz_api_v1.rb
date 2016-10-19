class QuizApiV1

	def self.asset_source
		"quiz-v1"
	end

	def self.records
		AssetFile.where(source: self.asset_source)
	end

	def self.quizzes
		self.records.group(:slug)
	end

	def self.newest_version_for_slug slug
		self.records.where(slug: slug).order('created_at DESC').first
	end

	def self.create_inline slug: nil, content: nil
		asset = AssetFile.create!(source: self.asset_source, slug: slug)
		asset.inline_upload(content)
		return asset
	end

	def self.post_preview_content(json_url)
		<<-EOF
		<style>p:last-of-type:after { display: none !important; }</style>
		<script type="text/javascript" src="https://d229kj59cs0571.cloudfront.net/quizbuilder/v1/app.js"></script><div id="g-container" data-quiz="#{json_url}"></div>
		EOF
	end

end