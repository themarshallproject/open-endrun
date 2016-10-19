class PullDocumentCloud
	include Sidekiq::Worker
	sidekiq_options :retry => false
	
	def perform(document_id)
		ActiveRecord::Base.connection_pool.with_connection do
			document = Document.find(document_id)
			document.pull_data
		end
	end
end
