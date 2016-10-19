require 'rails_helper'

RSpec.describe Stream, type: :model do

  it "has the methods for a Post object" do
    post = create(:published_post)
    expect(Post.stream(1.hour.ago, 1.hour.from_now)).to include post
    expect(post.stream_sort_key).to respond_to(:to_i)
    expect(post.published?).to be true
    expect(post.in_stream?).to be true
  end

  # it "has the methods for a Letter object" do
  #   post = create(:published_post)
  #   expect(Post.stream(1.hour.ago, 1.hour.from_now)).to eq([post])
  #   expect(post.stream_sort_key).to respond_to(:to_i)
  #   expect(post.published?).to be true
  #   expect(post.in_stream?).to be true
  # end


  it "has a main() stream" do
    post1 = create(:published_post, published_at: 2.minutes.ago, revised_at: 2.minutes.ago)
    post2 = create(:published_post, published_at: 3.minutes.ago, revised_at: 3.minutes.ago)
    expect(Stream.new.items).to include(post1)
    expect(Stream.new.items).to include(post2)
  end

  it "has a tag() stream" do
    post = create(:published_post)
    tag = create(:tag)
    post.rubric = tag
    expect(Stream.new(tag: tag).items).to include post
  end

  it "has an author() stream" do
    ignore_post = create(:published_post)

    post = create(:published_post)
    user = create(:user)
    post.authors = [user.id]

    expect(Stream.new(author: user).items).to include post
  end

  it "ignores unpublished posts" do
    post = create(:post)
    expect(Stream.new.items).to_not include post
  end

end
