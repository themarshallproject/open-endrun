class FeatureFlag < ActiveRecord::Base
	include Skylight::Helpers

	def self.active?(name)
		# global, public flag
		Skylight.instrument title: "Check Feature Flag #{name}" do
			return false if name.nil?
			return Rails.cache.fetch("feature_flag/v1/#{name.to_s}", expires_in: 5.seconds) {
				where(key: name.to_s, value: "true").first.present?
			}
		end
	rescue
		puts "FeatureFlag.active? error: #{$!}"
		false
	end

	def self.enable!(name)		
		# global, public flag
		where(key: name.to_s).first_or_create.update(value: "true")
		self.notify_slack(name, "true")
	end

	def self.disable!(name)
		# global, public flag
		where(key: name.to_s).update_all(value: "false")
		self.notify_slack(name, "false")
	end

	def self.notify_slack(name, state)
		# global, public flag
		Slack.perform_async('SLACK_DEV_LOGS_URL', {
				channel: "#dev_logs",
				username: "FeatureFlag",
				text: "*#{name}* is now *#{state}*",
				icon_emoji: ":triangular_flag_on_post:"
		})
		nil
	end

	def self.all_per_user_flags
		Hashie::Mash.new(YAML.load_file(File.join(Rails.root, 'config', 'feature_flag_config.yml')))
	end	

end