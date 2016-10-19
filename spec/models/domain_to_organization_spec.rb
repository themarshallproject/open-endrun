require 'rails_helper'

RSpec.describe DomainToOrganization, type: :model do
  it "converts a known domain to an org" do
    expect(DomainToOrganization.lookup('nytimes.com')).to eq "The New York Times"
    expect(DomainToOrganization.lookup('washingtonpost.com')).to eq "The Washington Post"
  end

  it "passes through an unknown domain" do
    expect(DomainToOrganization.lookup('not-news.com')).to eq "not-news.com"
  end

  it "doesnt explode for nil and returns an empty string" do
    expect(DomainToOrganization.lookup(nil)).to eq ''
  end
end
