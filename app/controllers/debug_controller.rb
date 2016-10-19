class DebugController < ApplicationController
  before_action :verify_current_user_present	
  def throw_error
  	raise "I have no idea what I'm doing."
  end
end
