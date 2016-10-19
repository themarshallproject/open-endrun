namespace :ga_rollup do
	task default: :environment do 
		urls = Post.published.all.map(&:canonical_url)
	    puts "downloading thriller snapshot for #{urls.count} url..."
	    @thriller = Thriller.new.social_snapshot(urls)
	    
	    puts "reading GA tsv exports..."
	    @ga_file       = File.open(File.join(Rails.root, 'data', 'ga_snapshot_1.tsv')).read.split("\n").map{|l| l.split("\t") }    
	    @ga_scroll     = File.open(File.join(Rails.root, 'data', 'ga_scrolldepth_page_1.tsv')).read.split("\n").map{|l| l.split("\t") }    
	    @ga_sharetools = File.open(File.join(Rails.root, 'data', 'ga_sharetools_page_1.tsv')).read.split("\n").map{|l| l.split("\t") }    
	    
	    puts "grabbing all Posts"
	    @posts = Post.published.order('published_at DESC').all

	    f = File.open(File.join(Rails.root, 'data', 'ga_auto_export.tsv'), 'w')

	    f.puts([
	    	"path",
	    	"published_at",
	    	"title",
	    	"word_count",
	    	"rubric",
	    	"authors",
	    	"lte_count",
	    	"has_inline_photo",
	    	"has_lead_photo",
	    	"pageviews",
	    	"facebook_count",
	    	"twitter_count",
	    	"scroll:20%",
	    	"scroll:40%",
	    	"scroll:60%",
	    	"scroll:80%",
	    	"scroll:100%",
	    	"share_tools_facebook",
	    	"share_tools_twitter",
	    	"share_tools_mailto",
	    	"share_tools_print",
	    ].join("\t"))

		@posts.each do |post|
				puts "#{post.title}"	

				pageviews = @ga_file.select{|row|
					row[0].include?(post.path)
				}.map{|row|
					row[1].gsub(",", "").gsub("\"", "").to_i # pageviews
				}.reduce(:+)

				thriller_row = @thriller['links'].select{|row| row['url'].include?(post.path) }.first

				scroll_events = @ga_scroll.select{|row| row[1].include?(post.path) } 
				zero_counts = scroll_events.select{|event|
					event[0] == '0%'
				}.first[2].gsub(",", "").gsub("\"", "").to_i rescue 9999999999

				percents = {}
				[0, 20, 40, 60, 80, 100].each do |percent|
					row = scroll_events.select{|event|
						event[0] == "#{percent}%"
					}.first rescue []

					count = row[2].gsub(",", "").gsub("\"", "").to_i rescue -1

					percents[percent.to_s] = "#{(100.0 * count / zero_counts).to_i}%"
				end
				
				share_tools = {} 
				['facebook', 'twitter', 'mailto', 'print'].each do |action|
					row = @ga_sharetools.select{|row|
					   		row[1].include?(post.path) and row[0] == "#{action}:click"
					}.first
					share_tools[action] = row[3] rescue row
				end
				
				f.puts([ 
					post.path,
					post.published_at.strftime('%m/%d/%Y'),
					post.title,
					post.word_count,
					post.rubric.name,
					post.authors.map(&:name).join(", "),
					post.letters.count,
					post.content.include?('[photo'),
					post.lead_photo.present?,
					pageviews,
					(thriller_row['facebook'] rescue nil),
					(thriller_row['twitter'] rescue nil),
					percents['20'],
					percents['40'],
					percents['60'],
					percents['80'],
					percents['100'],
					share_tools['facebook'],
					share_tools['twitter'],
					share_tools['mailto'],
					share_tools['print'] 
				].join("\t"))
		end

	end
end
    
