namespace :index_tags do
	task default: :environment do 
		ES.index_all_tags
	end
end
