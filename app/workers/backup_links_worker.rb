class BackupLinksWorker
	include Sidekiq::Worker

	def perform		
		ActiveRecord::Base.connection_pool.with_connection do
			json = Link.all.map{|link|
				link.attributes.except(:html).merge({exported_at: Time.now.utc.to_i})
			}.to_json
		end
		S3Upload.perform_async(
			access_key: 'AKIAJ4ASAV3CGL3BX6DA',
			access_secret: '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',
			bucket: 'tmp-nkpzf',
			key: "#{ENV['RACK_ENV']}/link_json_backup/#{Time.now.utc.to_i}.json",
			acl: :public_read,
			contents: json
		)
	end
end