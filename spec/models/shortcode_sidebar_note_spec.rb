require 'rails_helper'

RSpec.describe ShortcodeSidebarNote, type: :model do

  it "extracts the simple case" do
    post = build(:post)
    post.content = "first\n\n[sidebar-note]Reported and published in collaboration with (NPR)[http://npr.com].[/sidebar-note]\n\nlast\n"
    expect(post.rendered_content).to eq("<p>first</p>\n\n<div class=\"shortcode-sidebar-note-shim\"><div class=\"shortcode-sidebar-note-inner\">Reported and published in collaboration with (NPR)[http://npr.com].</div></div>\n\n<p>last</p>\n")
  end

end

