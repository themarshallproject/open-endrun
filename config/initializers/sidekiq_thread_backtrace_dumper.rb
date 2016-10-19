# if ENV['SIDEKIQ'] == 'true'
# 	Sidekiq.default_worker_options = { 'backtrace' => true }

# 	Thread.new do 
# 		sleep 30
# 		loop do
# 			puts "SIDEKIQ_THREAD_BACKTRACES: "+JSON.generate(
# 				Thread.list.map{ |thread|
# 					{
# 						tid: "Thread TID-#{thread.object_id.to_s(36)} #{thread['label']}",
# 						backtrace: thread.try(:backtrace)
# 					}
# 				}
# 			)
# 			sleep 300
# 		end
# 	end
# end