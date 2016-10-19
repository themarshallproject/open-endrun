class ShortcodeArgumentParser
	attr_reader :argument_string
	def initialize(argument_string)
		@argument_string = argument_string.to_s # nil guard
		self
	end

	def matches
		# format:    k="a string"
		# or format: k='a string'
		quote_re = /(\S+)=('|")(.+?)('|")/
		quote_matches = argument_string.scan(quote_re).map do |k, _, v, _|
			[k, v]
		end

		# format: k=v
		noquote_re = /(\S+)=([^'"\s]+)/
		noquote_matches = argument_string.scan(noquote_re).map do |k, v|
			[k, v]
		end

		quote_matches + noquote_matches
	end

	def parse
		matches.inject(ActiveSupport::HashWithIndifferentAccess.new) do |obj, (k, v)|
			obj[clean_key(k)] = clean_value(v)
			obj
		end
	end

	private

		def clean_key(k)
			k
		end

		def clean_value(v)
			v
		end

end