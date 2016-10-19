# in .endrun_token -- TOKEN=Y1c-gpyhzztdcNqmdLmuJQ TARGET=development 
# ruby ~/code/endrun/utils/post_deploy_token_client.rb .endrun_token

require 'json'
require 'httparty'
require 'nokogiri'
require 'dotenv'

Dotenv.load(ARGV.first)

base_url = {
	"production" => "https://www.themarshallproject.org",
	"staging" => "https://endrun-staging.herokuapp.com",
	"development" => "http://endrun.dev"
}[ENV['TARGET']]
path = "/admin/api/v1/update-post"

raise "Need ENV vars TARGET and TOKEN to deploy" if ENV['TARGET'].nil? or ENV['TOKEN'].nil?

def base_path
	Dir.pwd
end

def html_path
	File.join(base_path, "_site/index.html")
end

def css_path
	File.join(base_path, "_site/assets/css/main.css")
end

def js_path
	File.join(base_path, "_site/assets/js/main.js")
end

def content

	raw_html = File.open(html_path).read
	doc = Nokogiri::HTML(raw_html)
	html = doc.css('.g-container').inner_html

	css = File.open(css_path).read
	js = File.open(js_path).read

	return [
		"<!-- GENERATED DO NOT EDIT BELOW -->",
		"<script>\n#{js}\n</script>",
		"<style>\n#{css}\n</style>",
		html,
		"<!-- GENERATED DO NOT EDIT ABOVE -->",
	].join("\n\n")

end

puts HTTParty.post(
	base_url+path, 
	body: JSON.generate({ 
		token: ENV['TOKEN'], 
		content: content()
	}), 
	headers: {
		'Content-Type' => 'application/json'
	}
).body