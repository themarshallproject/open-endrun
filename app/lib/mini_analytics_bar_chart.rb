class MiniAnalyticsBarChart
	def initialize(daily: 1000, total: 2000, domain_max: 10000)
		@daily = daily
		@total = total
		@image = MiniMagick::Image.open(File.join(Rails.root, 'app', 'assets', 'images', '1px_empty.png'))
		@domain_max = domain_max
		self.layout()
	end

	def width
		180
	end

	def height
		15
	end

	def reference_line
		2000
	end

	def x input
		(1.0*input/@domain_max) * width
	end


	def layout
		@image.resize "#{width}x#{height}!"
		@image.draw "fill #ff0b3a rectangle 0,0 #{x(@total)},#{height}"
		@image.draw "fill #1FBEC3 rectangle 0,0 #{x(@daily)},#{height}"
		@image.draw "fill #333333 rectangle #{x(reference_line)},0, #{x(reference_line)+1},#{height}"
		self
	end

	def base64
		Base64.encode64(@image.to_blob).gsub("\n", "")
	end

	def debug
		tempfile = Tempfile.new('t').path
		@image.write(tempfile)
		`open "#{tempfile}"` # obviously this does not work in the cloud...
	end
end