require 'rails_helper'

RSpec.describe ShortcodeSectionBreak, type: :model do

  it "extracts the simple case" do
    post = build(:post)
    post.content = "here is some text\n\n[section-break]tktktk[/section-break]\n\nand some more text"
    expect(post.rendered_content).to eq("<p>here is some text</p>\n\n<div class='shortcode-section-break'>tktktk</div>\n\n<p>and some more text</p>\n")
  end

  it "doesnt work for unbalanced tags" do
    post = build(:post)
    post.content = "here is some text\n\n[section-break]\n\nand some more text"
    expect(post.rendered_content).to eq("<p>here is some text</p>\n\n[section-break]\n\n<p>and some more text</p>\n")
  end

  it "works for multiple" do
    post = build(:post)
    post.content = "first\n\n[section-break]tktktk[/section-break]\n\nsecond\n\n[section-break]testtest[/section-break]\n\n"
    expect(post.rendered_content).to eq("<p>first</p>\n\n<div class='shortcode-section-break'>tktktk</div>\n\n<p>second</p>\n\n<div class='shortcode-section-break'>testtest</div>\n")
  end

end
