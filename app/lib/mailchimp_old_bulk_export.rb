class MailchimpOldBulkExport

	def initialize
		@data = nil
	end

	def data
		@data
	end

	def find_by_email(email)
		data.select do |row|
			row['Email Address'].strip.downcase == email.strip.downcase
		end
	end

	def load
		@data = JSON.parse File.open(path).read
	end

	def path
		File.join(Rails.root, 'data', 'mailchimp_api_bulk_export.json')
	end

	def load_or_download
		if File.exists?(path)
			load()
		else
			download!
		end

		self
	end

	def download!
		puts "downloading..."
		apikey = ENV['MAILCHIMP_API_KEY']
		id = ENV['MAILCHIMP_PROD_LIST']
		url = "http://us3.api.mailchimp.com/export/1.0/list/?apikey=#{apikey}&id=#{id}"
		req = HTTParty.get(url)
		header, *rows = req.body.split("\n").map do |row|
			JSON.parse(row)
		end

		puts "processing..."
		@data = rows.inject([]){ |obj, item|
			blob = {}
			item.each_with_index{|col_val, col_index|
				key = header[col_index]
				blob[key] = col_val
			}
			obj << blob
			obj
		}

		puts "saving to #{path}"
		File.open(path, 'w') do |f|
			f.puts(JSON.generate(@data))
		end
		puts "done"
	end

end
