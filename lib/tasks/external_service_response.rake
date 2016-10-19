namespace :external_service_response do
  desc "Pull new TopShelf data from Thriller"
  task update_facebook_topshelf: :environment do
  	FacebookRecentPostSharesV1Worker.new.perform
  end

end
