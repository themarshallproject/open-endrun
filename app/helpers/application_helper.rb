module ApplicationHelper

  def find_meta_viewport(user: nil, requested_width: nil)
    if user.present? and requested_width.present?
      "width=#{requested_width}"
    else
      "width=device-width, initial-scale=1.0, user-scalable=no"
    end
  end

  def markdown(text)
  	text ||= ""
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text).html_safe
  end

  def escape_url(url)
    URI.escape(url.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def clean_headline(text)
  	text.split(' ').each_with_index.map do |word, index|
  		if word.slice(0,3).upcase == word.slice(0,3)
  			# allow anything that starts with three uppercase chars (acronyms thru)
        # passing thru means "FBI's" wont get mangled
  			word
      elsif /[^a-zA-Z]/.match(word[0])
        # pass thru if it starts with a non-letter
        word
  		elsif (%{a an the and but or for nor on in}.include?(word.downcase)) and (index > 0)
  			word.downcase
  		else
  			word.capitalize
  		end
  	end.join(' ')
  rescue
    logger.error("error in clean_headline for #{text}")
  	text
  end

end
