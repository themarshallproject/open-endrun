class UpdateDocumentPublishedURL
	include Sidekiq::Worker
	sidekiq_options :retry => false
	
	def perform(document_id)
		ActiveRecord::Base.connection_pool.with_connection do
			document = Document.find(document_id)
			document.update_published_url
		end
	end
end
