require 'rails_helper'

RSpec.describe "PublicHome", type: :feature do

  before :each do
    @post = create(:published_post, published_at: 1.day.ago)
  end

  it "have a link to the about page and the donate page" do
    visit root_path

    expect(page).to have_content('About')
    expect(page).to have_content('Donate')
  end

  it 'should return an empty set of opened posts', js: true do
    visit(root_path)
    expect(evaluate_script("window.prefetching_posts")).to eq([])
    # expect(evaluate_script("window.get_open_stories()")).to eq([])
    expect(evaluate_script("window.stream_keys()")).to include("post:#{@post.id}")

    # # wait_until { page.find("section.stream-post").visible? }
    # save_screenshot('stream-unopen.png')

    # first("section.stream-post").click
    # wait_until { page.find("h1.post-headline").visible? }
    # save_screenshot('streampostopen.png')

    # expect(evaluate_script("window.get_open_stories()[0].getAttribute('data-post-id')")).to eq([])
  end

  scenario "visits a public post page" do
    visit @post.path
    expect(page).to have_content(@post.title)
    expect(page).to have_content(@post.content)
    expect(page).to have_content(@post.rubric.name)

    [
      '<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">',
      '<meta property="og:image"',
      '<meta property="og:site_name"',
      '<meta property="og:url"',
      '<meta property="og:title"',
      '<meta property="og:description"',
      '<link rel="canonical" href',
    ].each do |chunk|
      expect(page.body).to include(chunk)
    end

  end

end
