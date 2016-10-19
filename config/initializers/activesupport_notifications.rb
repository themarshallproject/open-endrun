# ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
#     #duration = ((finish - start) * 1000).round(0)
#     [:view_runtime, :db_runtime].each do |key|
#         if payload[key].present?            
#             $stdout.puts("measure#app.#{key}=#{payload[key].round(0)}ms")
#         end
#     end
# end