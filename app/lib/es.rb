class ES
	def initialize
		@client ||= Elasticsearch::Client.new(url: ENV[ENV['ELASTICSEARCH_VAR']])
		@client
	end

	def client
		@client
	end

	def health
		self.client.health
	end

	def index_post(post_id)
		post = Post.find(post_id)

		self.client.index(
			index: 'posts',
			type: 'post',
			id: post.id,
			body: {
				title: post.title,
				deck: post.deck,
				content: post.content,
				authors: post.authors.map(&:name),
				produced_by: post.produced_by,
				byline: Nokogiri::HTML(post.byline).text
			}
		)
	end

	def search(q)
		puts "SearchQuery: #{q}"
		$stdout.puts("count#app.search_performed=1")
		self.client.search(
			index: 'posts',
			body: {
				from: 0,
				size: 100,
				query: {
					match: {
						"_all" => q
					}
				}
			}
		)
	end

	def self.index_all_published_posts
		$stdout.puts("count#app.search_index_all_posts=1")
		client = ES.new
		Post.published.all.each do |post|
			client.index_post(post.id)
		end
	end

	##############
	### GATOR!
	##############

	def self.index_all_links
		$stdout.puts("count#app.search_index_all_links=1")
		client = ES.new.client
		Link.all.each do |link|
			puts "Indexing Link url=#{link.url}"
			begin
				client.index(
					index: 'links',
					type: 'link',
					id: link.id,
					body: {
						text: link.doc.text,
						tag_names: link.tag_names,
						url: link.url
					}
				)
			rescue
				puts "ERROR indexing url=#{link.url}"
			end
		end
	end

	def self.search_links(query: nil, size: 100)
		client = ES.new.client
		client.search(
			index: 'links',
			body: {
				size: size,
				query: {
					match: {
						"_all" => query
					}
				}
			}
		)
	end

	# tags

	def self.index_all_tags
		client = ES.new.client
		Tag.where.not(tag_type: 'category').all.each do |tag|

			puts "Indexing Tag id=#{tag.id} name='#{tag.name}'"

			links = tag.links.last(20).map{|l| l.try(:taggable) }.map{|l| l.try(:title) }

			begin
				client.index(
					index: 'tags',
					type: 'tag',
					id: tag.id,
					body: {
						slug: tag.slug,
						name: tag.name,
						recent_link_titles: links
					}
				)
			rescue
				puts "ERROR indexing tag_id=#{tag.id}"
			end
		end
	end

	def self.index_tag(tag_id)
		client = ES.new.client
		tag = Tag.find(tag_id)
		links = tag.links.last(20).map{|l| l.try(:taggable) }.map{|l| l.try(:title) }
		client.index(
			index: 'tags',
			type: 'tag',
			id: tag.id,
			body: {
				slug: tag.slug,
				name: tag.name,
				recent_link_titles: links
			}
		)
	end

	def self.search_tags(query)
		client = ES.new.client
		tag_ids = client.search(
			index: 'tags',
			body: {
				size: 200,
				query: {
					term: {
						name: query
					}
				}
			}
		)['hits']['hits'].map{ |hit|
			hit['_id']
		}

		Tag.where.not(tag_type: 'category').where(id: tag_ids)
	end


end
