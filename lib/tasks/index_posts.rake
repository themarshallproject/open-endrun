namespace :index_posts do
	task default: :environment do 
		start = Time.now.utc.to_f
		ESIndexAllPostsWorker.new.perform
		puts "ESIndexAllPostsWorker took #{Time.now.utc.to_f - start}"
	end
end
