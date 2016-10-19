class EmailUserReport
  def users
    EmailSignup.all
  end
  def process_all
    data = users.order('created_at ASC').map do |user|
      process(user)
    end

    error_count = data.select(&:nil?).count
    rows = data.reject(&:nil?)

    puts "errors: #{error_count}"
    puts rows.select{|row| row[:groups].count == 0 }.map{|row| [row[:email], row[:groups]].join(',') }.join("\n")
  end

  def lookup_interest(id)
    {
      "x" => "opening_statement",
      "y" => "closing_argument",
      "z" => "occasional_updates",
    }
    id
  end

  def extract_groups(interests)
    interests.select{ |_, val|
      val == true
    }.map{ |id, _|
      lookup_interest(id)
    }
  end

  def extract_mailchimp(user)
    begin
      mailchimp = JSON.parse(user.mailchimp_data)
      # puts mailchimp
      return mailchimp
    rescue
      # puts "error parsing #{user}"
      return nil
    end
  end

  def process(user)
    mailchimp = extract_mailchimp(user)
    if mailchimp.nil?
      return nil
    end

    created = user.created_at.strftime('%Y-%m-%d')
    groups = extract_groups(mailchimp['interests'])

    options = user.options_on_create

    return {
      id: user.id,
      email: user.email.downcase,
      created: created,
      status: mailchimp['status'],
      groups: groups,
      mailchimp_rating: mailchimp['member_rating'],
      avg_open_rate: mailchimp['stats']['avg_open_rate'],
      avg_click_rate: mailchimp['stats']['avg_click_rate'],
      signup_source: (user.signup_source rescue 'unknown'),
      placement: (options['placement'] rescue 'unknown'),
      referrer: (options['referer'] rescue 'unknown'),
    }
  end
end
