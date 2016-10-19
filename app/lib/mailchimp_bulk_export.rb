class MailchimpBulkExport

  attr_reader :apikey
  attr_reader :dc
  attr_reader :bucket

  def initialize(apikey: ENV['MAILCHIMP_API_KEY'])
    @apikey = apikey
    @dc = apikey.split("-").last

    s3 = AWS::S3.new(access_key_id: ENV['S3_MAILCHIMP_LOGS_ACCESS_KEY'], secret_access_key: ENV['S3_MAILCHIMP_LOGS_SECRET_KEY'])
    bucket = ENV['S3_MAILCHIMP_LOGS_BUCKET']
    @bucket = s3.buckets[bucket]
  end

  # def list
  #   # tk
  # end

  def subscriber_activity(campaign_id: nil)
    campaign_id.gsub!(/[^0-9a-zA-Z]/)

    start_time = Time.now.utc.to_f
    puts "MailchimpBulkExport#subscriber_activity :: START campaign_id=#{campaign_id}"

    tempfile = Tempfile.new('mc')

    url = subscriber_activity_url(campaign_id)
    system('curl', '--silent', '-o', tempfile.path, url) # TK TODO what happens when this fails? times out?

    s3_key = subscriber_activity_s3_key(campaign_id)
    s3_obj = bucket.objects[s3_key].write(file: tempfile.path)

    elapsed_seconds = Time.now.utc.to_f - start_time
    puts "MailchimpBulkExport#subscriber_activity :: DONE campaign_id=#{campaign_id} :: #{elapsed_seconds}sec"
    return s3_obj
  end

  private

    def base_url
      "https://#{dc}.api.mailchimp.com/export/1.0"
    end

    # subscriber activity export helpers

    def subscriber_activity_url(campaign_id)
      raise "No campaign_id" if campaign_id.nil?
      "#{base_url}/campaignSubscriberActivity/?apikey=#{apikey}&id=#{campaign_id}"
    end

    def subscriber_activity_s3_key(campaign_id)
      "bulk/subscriber_activity/#{campaign_id}.json"
    end

    # subscriber activity export helpers

    # def list_url(list_id)
    #   raise "No list_id" if list_id.nil?
    #   # "#{base_url}/TKTKTK/?apikey=#{apikey}&id=#{list_id}"
    # end

    # def list_s3_key(list_id)
    #   "bulk/list/#{list_id}.json"
    # end

end
