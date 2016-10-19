require 'yaml'
require 'httparty'

settings = YAML.load_file(
	File.join(
		File.dirname(__FILE__), '..', '.endrun_config'
	)
)

puts ARGV.inspect

response = HTTParty.post(
	settings['api_v1_post_preview_endpoint'], 
	body: {
		api_key: settings['api_v1_post_preview_api_key'],
		content: File.open(ARGV.first).read,
		post_format: ARGV[1] || 'base'
	}
)

puts response.code

`open #{response.body}`
