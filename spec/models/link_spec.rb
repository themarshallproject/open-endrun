require 'rails_helper'

RSpec.describe Link, type: :model do
  it "is alive by default" do
    link = create(:link)
    expect(link.remote_is_alive).to be true
  end

  it "correctly looks up the domain if known" do
    random = SecureRandom.hex
    link = create(:link, url: "http://nytimes.com/a-story-#{random}", title: 'the-title', domain: 'nytimes.com')
    expect(link.default_email_content).to eq("the-title [The New York Times](http://nytimes.com/a-story-#{random})")
  end

  it "generates a display_title" do
    ["|", "-"].each do |sep| # TODO expand this?
       link = build(:link, title: "The Title #{sep} Org")
       expect(link.display_title).to eq("The Title")
    end
  end

  it "is approved by default" do
    link = create(:link)
    expect(link.approved?).to be true
  end

  it "correctly marks itself as alive if remote is alive" do
    link = create(:link, url: 'https://www.google.com')
    link.update_remote_status!
    expect(link.remote_is_alive).to be true
  end

    it "correctly marks itself as *not* alive if remote is *not* alive" do
    link = create(:link, url: 'https://www.themarshallproject.org/this-will-404-otherwise-ouch')
    link.update_remote_status!
    expect(link.remote_is_alive).to be false
  end

end
