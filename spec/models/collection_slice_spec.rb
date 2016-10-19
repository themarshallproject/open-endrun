require 'rails_helper'

RSpec.describe CollectionSlice, type: :model do

  it "has a working redis client" do
    tag = Tag.create!(name: SecureRandom.hex, tag_type: 'topic')
    slice = CollectionSlice.new(tag_id: tag.id, models: ['link'], slice: :date)
    key = SecureRandom.hex
    val = SecureRandom.hex
    slice.redis.with do |conn|
      conn.set(key, val)
      expect(conn.get(key)).to eq(val)
    end
  end

  it "has a working memcached client" do
    key, val = key = "k_#{SecureRandom.hex}", "v_#{SecureRandom.hex}"
    Rails.cache.write(key, val)
    expect(Rails.cache.read(key)).to eq(val)
  end

  it "can convert a domain to an organization" do
    presenter = CollectionItemPresenter.new(nil)
    expect(presenter.domain_to_organization('nytimes.com')).to eq("The New York Times")
    expect(presenter.domain_to_organization('washingtonpost.com')).to eq("The Washington Post")
    expect(presenter.domain_to_organization('xxxxxunknown.com')).to eq("xxxxxunknown.com")
  end

  it "correctly returns empty slices for models:[link], types :facebook_likes, :date" do
    tag = Tag.create!(name: "tag_#{SecureRandom.hex}", tag_type: 'topic')

    created_slice = CollectionSlice.new(tag_id: tag.id, models: ['link'], slice: :date)
    expect(created_slice.slow_fetch_database_items).to eq([])
    expect(created_slice.slice_key).to eq("v1|tag=#{tag.id}|models=link|slice=date")

    facebook_slice = CollectionSlice.new(tag_id: tag.id, models: ['link'], slice: :facebook_count)
    expect(facebook_slice.slow_fetch_database_items).to eq([])
    expect(facebook_slice.slice_key).to eq("v1|tag=#{tag.id}|models=link|slice=facebook_count")
  end

  it "creates a set of models internally and ignores invalid model strings" do
    tag = Tag.create!(name: "tag_#{SecureRandom.hex}", tag_type: 'topic')

    expect(CollectionSlice.new(tag_id: tag.id, models: ['invalid'],                 slice: :date).models).to eq([]) # filter
    expect(CollectionSlice.new(tag_id: tag.id, models: ['link'],                    slice: :date).models).to eq([Link])
    expect(CollectionSlice.new(tag_id: tag.id, models: ['post'],                    slice: :date).models).to eq([Post])
    expect(CollectionSlice.new(tag_id: tag.id, models: ['post', 'post'],            slice: :date).models).to eq([Post]) # de-dupe
    expect(CollectionSlice.new(tag_id: tag.id, models: ['link', 'post'],            slice: :date).models).to eq([Link, Post])
    expect(CollectionSlice.new(tag_id: tag.id, models: ['link', 'post', 'invalid'], slice: :date).models).to eq([Link, Post]) # filter invalid
    expect(CollectionSlice.new(tag_id: tag.id, models: ['link', 'post', 'tag'],     slice: :date).models).to eq([Link, Post]) # filter valid
  end

  it "rebuilds a tag's slices when a new tagging is created" do
    tag = create(:tag)
    link = create(:link)

    Sidekiq::Testing.inline! do
      tag.attach_to(link).save
      slice = CollectionSlice.new(tag_id: tag.id, models: ['link'], slice: :date)
      expect(slice.memcached_records).to eq([["link:#{link.id}", link.created_at.to_i]])
    end

  end

  it "correctly generates a date slice" do
    tag = Tag.create!(name: "dateslice_#{SecureRandom.hex}", tag_type: 'topic')
    Tagging.where(tag_id: tag.id).delete_all

    slice = CollectionSlice.new(tag_id: tag.id, models: ['link', 'post'], slice: :date)

    link = create(:link)
    tag.attach_to(link).save
    link.update_attribute(:created_at, Time.at(30000))

    ignore_post = create(:published_post)

    post = create(:published_post)
    tag.attach_to(post).save
    post.update_attribute(:published_at, Time.at(20000))
    post.update_attribute(:revised_at,   Time.at(20000))

    expect(slice.slow_fetch_database_items).to eq([link, post])

    expect(slice.key_for(post)).to eq("post:#{post.id}")
    expect(slice.date(post)).to eq(post.revised_at.utc.to_i)

    expect(slice.key_for(link)).to eq("link:#{link.id}")
    expect(slice.date(link)).to eq(link.created_at.utc.to_i)

    slice.generate_memcached
    expect(slice.memcached_records).to eq([["link:#{link.id}", 30000.0], ["post:#{post.id}", 20000.0]])

    result_link = slice.result.first
    expect(result_link[:model]).to eq('link')
    expect(result_link[:url]).to   eq(link.url)
    expect(result_link[:title]).to eq(link.title)

    result_post = slice.result.second
    expect(result_post[:model]).to eq('post')
    expect(result_post[:path]).to  include(post.path)
    expect(result_post[:title]).to eq(post.title)

    out_of_bounds_slice = CollectionSlice.new(tag_id: tag.id, models: ['link', 'post'], slice: :date, page: 10)
    expect(out_of_bounds_slice.result).to eq([])
  end

  it "ignore non-public links" do
    tag = create(:tag)
    false_link = create(:link, approved: false)
    true_link  = create(:link, approved: true)
    tag.attach_to(false_link).save
    tag.attach_to(true_link).save
    slice = CollectionSlice.new(tag_id: tag.id, models: ['link'], slice: :date)
    slice.generate
    slice.generate_memcached
    expect(slice.result.count).to eq 1
    expect(slice.result.first['id']).to eq(true_link.id)
  end


end
