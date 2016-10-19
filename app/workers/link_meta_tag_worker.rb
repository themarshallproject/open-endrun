class LinkMetaTagWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(link_id)
    link = Link.find_by(id: link_id)
    if link.present?
      link.update_meta_tags!
    end
  end

end