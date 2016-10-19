require 'rails_helper'

RSpec.describe Post, type: :model do

  it 'is invalid without args' do
    expect(Post.new).to_not be_valid # not using build() because it should *not* be valid
  end

  it 'has defaults' do
  	post = create(:post)
  	expect(post.status).to       eql('draft')
  	expect(post.post_format).to  eql('base')
  	expect(post.stream_promo).to eql('base')
  end

  it 'has a draft and published states, in that order' do
  	expect(build(:post).states['draft'].present?).to     be(true)
  	expect(build(:post).states['published'].present?).to be(true)
    expect(build(:post).states.keys).to eq(["draft", "published"])
  end

  it 'generates a slug and path' do
  	# 1452195125 == 2016-01-07 14:31:59 -0500
    post = create(:post, published_at: Time.at(1452195125))
  	expected_slug = post.title.parameterize

  	expect(post.slug).to eq(expected_slug)
  	expect(post.path).to eq("/#{post.published_at.strftime('%Y/%m/%d')}/#{expected_slug}")
  end

  it 'allows broken scss' do
  	post = build(:post, custom_scss: "broken")
  	expect(post.rendered_scss).to eql("/* Error rendering custom SCSS for post */")
  end

  it 'compiles custom scss' do
  	post = build(:post, custom_scss: ".klass { a { font-size: 12px }}")
  	expect(post.rendered_scss).to eql("/* auto generated */\n.post- .klass a {\n  font-size: 12px; }\n")
  end

  it 'renders basic markdown and does not inject content hashes' do
  	post = build(:post)
  	post.content = "some test and\n\n*ital* **bold** [link](src)"
  	expect(post.rendered_content).to eql("<p>some test and</p>\n\n<p><em>ital</em> <strong>bold</strong> <a href=\"src\">link</a></p>\n")
  end

  it 'tolerates an invalid lead photo' do
  	post = build(:post, lead_photo_id: 999)
  	expect(post.lead_photo).to eql(nil)
  end

  it "renders bylines by UserPostAssignment" do
    user1 = User.create!(name: "Za User",  email: "u_#{SecureRandom.hex}", password: SecureRandom.hex, slug: 'first-user')
    user2 = User.create!(name: "Aa User", email: "u_#{SecureRandom.hex}", password: SecureRandom.hex, slug: 'second-user')
    post = create(:post)
    post.authors = [user1.id, user2.id]
    expect(post.byline).to eq "By <span><a href=\"/staff/first-user\">Za User</a></span> and <span><a href=\"/staff/second-user\">Aa User</a></span>"
  end

  it "can override the byline" do
    test_override = "By <a href='http://nytimes.com'>The New York Times</a>"
    post = build(:post)
    post.byline_freeform = test_override
    expect(post.byline).to eq test_override
  end

  it 'starts with an empty redirects hash' do
  	expect(build(:post).redirects).to eq(nil)
  end

  it 'does not modify a produced_by author shortcode, but renders correctly via `metadata_provider`' do
    post = create(:post)
    user = create(:user, name: "First Last", slug: "first-last")
    expected_produced_by = "Graphics by [author first-last]"

    post.produced_by = expected_produced_by
    post.save
    post.reload

    expect(post.metadata_provider.produced_by).to eq("Graphics by <span><a href=\"/staff/first-last\">First Last</a></span>")
    expect(post.produced_by).to eq(expected_produced_by)
  end

  it 'calculates social_query_params' do
    post = Post.new
    param_string = post.social_query_params()
    expect(param_string).to eq("utm_medium=social&utm_campaign=share-tools")
  end

  it 'returns nil for missing rubric' do
    expect(Post.new.rubric_id).to be(nil)
  end

  it 'sets the redirects hash' do
   	post = Post.create!(title: "The First Title", content: SecureRandom.hex)
   	expected_first_slug = 'the-first-title'

   	expect(post.slug).to eq(expected_first_slug)
  	expect(Post.redirects(expected_first_slug).first.id).to eq(post.id)

  	# if we update the title, it will not change the slug
  	post.title = "The Second Title"
  	post.save
  	expect(post.slug).to eq(expected_first_slug)

  	# but if we empty the slug, it'll regenerate
  	post.slug = ""
  	post.save
  	expect(post.slug).to eq("the-second-title")

  	# check that we have both slugs in the redirects hash
  	expect(post.redirects.keys).to eq(["the-first-title", "the-second-title"])

  	# and that we can still get the post by the first slug
  	expect(Post.redirects(expected_first_slug).first.id).to eq(post.id)
  end

  it 'calculates word count' do
  	expect(Post.new(content: "this is a *test*").word_count).to eq(4)
  	expect(Post.new(content: "the quick\n\n\n\nbrown dog jumped").word_count).to eq(5)
  end

  it 'provides a stream sort key' do
  	expect(Post.new(revised_at: Time.now).stream_sort_key).to respond_to(:strftime)
  end

  it 'has an escaped, canonical url' do
    post = create(:post, title: 'the-headline', published_at: Time.at(1453304925))
    expect(post.escaped_canonical_url).to eq("https%3A%2F%2Fwww.themarshallproject.org%2F2016%2F01%2F20%2Fthe-headline")
  end

  it 'has a stream date slug' do
    time = Time.at(1453776561)
    expect(Post.new(revised_at: time, published_at: 1.year.ago).stream_dateslug).to eq("20160125")
  end

  it 'cannot be published without a rubric' do
    post = create(:post)
    post.status = 'published'
    post.save
    post.reload
    expect(post.status).to eq('draft')
  end

  it 'generates a featured block path with social_id' do
    path = Post.new(published_at: Time.at(1453304925)).featured_block_path(config: 'config', slot: 'slot')
    expect(path.split("#").first).to eq("/2016/01/20/?ref=hp-slot-config")
  end

  it 'is not locked by default' do
    post = Post.create!(title: 'title', content: 'content')
    expect(post.locked?).to eq(false)
  end

  it 'can be locked by a user' do
    user = User.create!(password: 'fake')
    post = Post.create!(title: 'title', content: 'content')

    PostLock.acquire(user: user, post: post)

    expect(post.locked?).to eq(true)
    expect(post.locked_by).to eq(user)
  end

  it 'can be locked by a user, then prevent a second user from obtaining a lock' do
    user1 = User.create!(email: SecureRandom.hex, password: 'fake')
    user2 = User.create!(email: SecureRandom.hex, password: 'fake')
    post = Post.create!(title: 'title', content: 'content')

    expected_valid_lock   = PostLock.acquire(user: user1, post: post)
    expected_invalid_lock = PostLock.acquire(user: user2, post: post)

    expect(post.locked_by).to eq(user1)
    expect(expected_valid_lock.stale?).to eq(false)
    expect(expected_valid_lock.locked_by?(user1)).to eq(true)
    expect(expected_valid_lock.locked_by?(user2)).to eq(false)
    expect(expected_invalid_lock).to eq(false)
  end

  it "is in_stream by default" do
    post = create(:post)
    expect(post.in_stream).to be(true)
  end

  it "can be removed from the stream" do
    post = create(:post)
    post.in_stream = false
    post.save
    post.reload
    expect(post.in_stream).to eq false
  end

  it "is in stream() by default" do
    post = create(:published_post)
    stream = Stream.new.items
    expect(stream.include?(post)).to be true
  end

  it "is not in stream.main if in_stream==false" do
    post = create(:published_post)
    post.in_stream = false
    post.save

    stream = Stream.new.items
    expect(stream.include?(post)).to be false
  end

  it "is in the tag stream when in_stream==false" do
    tag = create(:tag)

    post = create(:published_post)
    post.rubric = tag
    post.in_stream = false
    post.save

    stream = Stream.new(tag: tag).items
    expect(stream.include?(post)).to be true
  end

end
