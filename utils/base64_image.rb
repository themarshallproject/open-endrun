require 'base64'
puts [  "<img src=\"data:image/#{ARGV.first.split('.').last};base64,",
        Base64.encode64(
            File.open(ARGV.first, 'rb').read
        ).gsub("\n", ""),
        "\">"
     ].join('')


