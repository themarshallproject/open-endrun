class PretestController < ApplicationController
  def slow  	
  	@inject_public_cache_control = true
  	sleep 2
  	render plain: "slow #{Time.now.utc.to_s}"
  end

  def error
  	@inject_public_cache_control = true
  	if rand() < 0.9
  		render plain: "oops #{Time.now.utc.to_s}", status: 500
  	else
  		render plain: "ok #{Time.now.utc.to_s}"
  	end
  end

end
