#Rack::Attack.whitelist('allow from localhost') do |req|
  # Requests are allowed if the return value is truthy
#  '127.0.0.1' == req.ip
#end

# Rack::Attack.throttle('ip', limit: 20, period: 10) do |req|
#   # need to check that this is actually the right header
# 	req.ip
# end

Rack::Attack.throttle('partner_admin', limit: 5, period: 10) do |req|
	req.path.include?('/partner/')
end