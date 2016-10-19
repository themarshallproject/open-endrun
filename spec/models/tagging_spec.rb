require 'rails_helper'

RSpec.describe Tagging, type: :model do
  it "validates a minimum name length" do
    expect(Tag.new).to be_invalid
  end
  it "is valid with a name and tag_type" do
    expect(Tag.new(name: "name", tag_type: "type")).to be_valid
  end
  it "creates a slug based on the name, and updates it when the name changes" do
    tag = Tag.create!(name: "My Tag", tag_type: "type")
    expect(tag.slug).to eq("my-tag")
    tag.name = "Other Tag Name"
    tag.save
    tag.reload
    expect(tag.slug).to eq("other-tag-name")
  end
end