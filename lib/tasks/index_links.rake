namespace :index_links do
	task default: :environment do 
		start = Time.now.utc.to_f
		ESIndexAllLinksWorker.new.perform
		puts "ESIndexAllLinksWorker took #{Time.now.utc.to_f - start}"
	end
end
