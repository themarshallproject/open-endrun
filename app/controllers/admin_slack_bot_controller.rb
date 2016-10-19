class AdminSlackBotController < ApplicationController
  include ActionView::Helpers::DateHelper

  def incoming_slash_command
  	raise "No SLACK_SLASH_TOKEN set on the server, can't authenticate" unless ENV['SLACK_SLASH_TOKEN'].present?  	
  	raise "Invalid API Token" unless params[:token] == ENV['SLACK_SLASH_TOKEN']

  	command = (params[:text] || '').strip

  	result = process_command(command)

  	Slack.perform_async('SLACK_DEV_LOGS_URL', {
  		channel: "#digital",
  		username: "EndRun",
  		text: result,
  		icon_emoji: ":sailboat:"
  	})

  	render plain: result
  end

  private

   #  def lookup(command)
   #    {
   #      'style guide': :styleguide,
   #      'styleguide': :styleguide,
   #      'hi': :hello,
   #      'today\'s links': :todays_links
   #      'links': :links
   #    }[command.strip.downcase]
   #  end

  	# def process_command(command)
  	# 	puts "Slack Slash Command: #{command}"
  		
  	# 	return self.call(lookup(command)) if lookup(command)
      
  	# 	"I'm not sure what you mean by that."
  	# end

   #  def styleguide
   #    "<badlink>"
   #  end

   #  def todays_links
   #    start_time = DateTime.now.in_time_zone(Time.zone).beginning_of_day

   #    return "```" + Link.where('created_at > ?', start_time).order('created_at DESC').map do |link|
   #      "#{time_ago_in_words(link.created_at)} #{link.url} (#{link.creator.name})"
   #    end.join("\n") + "```"
   #  end

   #  def links
   #    "<https://www.themarshallproject.org/links>"
   #  end

   #  def hello
   #    "Hi!"
   #  end

end
