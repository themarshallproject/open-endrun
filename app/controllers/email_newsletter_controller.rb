require 'mailchimp'

class EmailNewsletterController < ApplicationController
  before_action :verify_current_user_present

  def setup_email
    @posts = Post.published.limit(12)
    @links = Link.published.limit(10)
    @html = render_to_string('show', layout: false)
  end

  def show
  	setup_email()

  	redirect_to S3SyncUpload.new.perform({
  		access_key: 'AKIAJ4ASAV3CGL3BX6DA',
  		access_secret: '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',
  		bucket: 'tmp-nkpzf',
  		key: "newsletter-v1/#{SecureRandom.uuid}.html",
  		contents: @html
  	})
  	
  end

  def generate
    setup_email()

    mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
    #lists = mailchimp.lists.list
    campaign = mailchimp.campaigns.create('regular', {
      list_id: ENV['MAILCHIMP_LIST_ID'],
      subject: 'Opening Statement',
      from_email: 'ivong@themarshallproject.org',
      from_name: 'Ivar Vong',
      to_name: '',
    }, {
      html: @html
    })

    logger.info campaign.inspect

    redirect_to "https://us3.admin.mailchimp.com/campaigns/wizard/confirm?id=#{campaign['web_id']}"
  end

  def search_archive
    if params[:q].present?
      @links = Link.where("email_content @@ ?", params[:q]).order('created_at DESC').all
      @assignments = NewsletterAssignment.where(taggable_type: 'Link', taggable_id: @links.map(&:id)).all
      @newsletters = Newsletter.where(id: @assignments.map(&:newsletter_id)).all
    end
  end

end
