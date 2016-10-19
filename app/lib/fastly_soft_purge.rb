# class FastlySoftPurge

#   # "Soft Purge" docs https://docs.fastly.com/api/purge#purge_5

#   attr_reader :service_id
#   attr_reader :api_key
#   attr_reader :post

#   def initialize(post: nil)
#     @api_key    = ENV['FASTLY_API_KEY']
#     @service_id = ENV['FASTLY_SERVICE_ID']
#   end

#   def key
#     # Apparently this does *not* need to be URL encoded, per:
#     # https://community.fastly.com/t/should-i-url-encode-the-purge-key-when-using-the-api/301
#     post.surrogate_key
#   end

#   def headers
#     {
#       "Fastly-Soft-Purge" => 1,
#       "Accept" => "application/json",
#       "Fastly-Key" => api_key,
#     }
#   end

#   def perform
#     HTTParty.post("https://api.fastly.com/#{service_id}/purge/#{key}", headers: headers)
#   end

# end
