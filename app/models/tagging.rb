class Tagging < ActiveRecord::Base
  belongs_to :tag, touch: true
  validates_presence_of :tag

  belongs_to :taggable, polymorphic: true, touch: true
  validates_presence_of :taggable

  belongs_to :user

  after_create   {
    RebuildAllTagsJSON.perform_async()
    self.tag.rebuild_collection_slices()
  }
  before_destroy {
    RebuildAllTagsJSON.perform_async()
  }

  def self.top_tags_from_taggables(type: 'Link', ids: [], limit: 10)
    self
      .where(taggable_type: type, taggable_id: ids.sort)
      .select("tag_id, count(*) as item_count")
      .group("tag_id")
      .order("item_count DESC")
      .limit(limit)
  end

  def self.top_tags(limit: 30, since: 1.week.ago, models: [Link])
    self
      .where('created_at > ?', since)
      .where(taggable_type: models)
      .select("tag_id, count(*) as item_count")
      .group("tag_id")
      .order("item_count desc")
      .limit(limit)
  end

  private

    def notify_change(text)
      Slack.perform_async('SLACK_DEV_LOGS_URL', {
        channel: "#tag_activity",
        username: "Dr. RattleCan",
        text: text,
        icon_emoji: ":doughnut:"
      })
    end

end
