namespace :social_count_snapshot do
	task recent_3days: :environment do
		Link.where('created_at > ?', 3.days.ago).all.shuffle.each do |link|
			puts "social_count_snapshot:recent_3days -- link id=#{link.id} url=#{link.url}"
			FacebookCountWorker.new.perform(link.id)
			sleep rand
		end
	end

	task recent_14days: :environment do
		Link.where('created_at > ?', 14.days.ago).each do |link|
			puts "social_count_snapshot:recent_14days -- link id=#{link.id} url=#{link.url}"
			FacebookCountWorker.new.perform(link.id)
			sleep rand
		end
	end

	task all: :environment do
		Link.all.shuffle.each do |link|
			puts "social_count_snapshot:all -- link id=#{link.id} url=#{link.url}"

			FacebookCountWorker.new.perform(link.id)
			
			sleep 0.5 + rand()
		end
	end
end