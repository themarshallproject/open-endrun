require 'open-uri'
require 'nokogiri'
require 'tempfile'
require 'aws-sdk'
require 'dotenv'
Dotenv.load

temp = Tempfile.new('t')

doc = Nokogiri::HTML(File.open(ARGV.first, 'r').read)

#css = doc.css('style').map(&:text)

artboards = doc.css('.g-artboard').map{|el| el.attr('id') }

$slug = artboards.first.split('-')[1..-2].join('-')

def upload(options={})
	# kword args: access_key, access_secret, bucket, key, contents
	# returns public url	
	Aws::S3::Client.new(region: 'us-east-1', access_key_id: ENV['S3_KEY'], secret_access_key: ENV['S3_SECRET'])
	  .put_object(
  		bucket: ENV['S3_BUCKET'],
  		key: options[:key],
  		body: options[:contents],
  		acl: 'public-read',
  		content_type: options[:content_type],
  		cache_control: "public, max_age=5"
  	  )
  	"https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/#{options[:key]}"

end

def upload_image(src)	
	path = File.join(Pathname.new(ARGV.first).dirname, src)
	puts "uploading #{path}"
	return upload({
		key: "dev/#{$slug}/#{src}",
		content_type: "image/jpg",
		contents: File.open(path, 'rb').read
	})
end


images = doc.css('img').map do |img| 
	{
		id: img.attr('id'),
		src: img.attr('src')
	}
end

images.map! do |image|	
	image.merge({
		uploaded_src: upload_image(image[:src])
	})
end

images.each do |image|
	doc.css("##{image[:id]}").attr('src', image[:uploaded_src])
end

def class_from_width(width)
	[   { start: 768,  end: 9999, class: 'tablet' },
		{ start: 0,    end: 767,  class: 'mobile' },
	].select{ |candidate|
		candidate[:start] <= width && width <= candidate[:end]
	}.first[:class]
end

css = []

artboards.each do |artboard|
	css << "##{artboard} { display: none; }"
end

artboards.each do |artboard|
	width = artboard.split('-').last.to_i	
	device = class_from_width(width)
	
	if device == 'mobile'
		css << "@media (max-width: 768px) {
			##{artboard} { display: block; } }"
	end

	if device == 'tablet'
		css << "@media (min-width: 768px) {
			##{artboard} { display: block; } }"
	end

end

css = ["<style>", css.join("\n"), "</style>\n\n"]

html = artboards.map{|artboard|
	el = doc.css("##{artboard}")
	#el.css('style').remove()
	el.to_html
}

contents = File.open('ai_preview_header.html', 'r').read + css.join("\n") + html.join("\n")

url = upload({
	key: "dev/#{$slug}/preview.html",
	content_type: 'text/html',
	contents: contents
})

`open #{url}`