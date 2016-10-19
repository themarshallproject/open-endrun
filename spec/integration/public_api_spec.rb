require 'rails_helper'

RSpec.describe "PublicAPI", type: :request do

  it 'gets a CSRF token' do
    get("/api/v2/token")
    data = JSON.parse(response.body)
    expect(response.status).to eq(200)
    expect(data['csrf'].length > 50).to eq(true)
    # expect(data['hash'].length >  5).to eq(true)
  end

  it "generates a 't' perma cookie during the CSRF request" do
    get("/api/v2/token")
    expect(response.status).to eq(200)
    response_cookies = CGI::Cookie::parse(response.headers['Set-Cookie'])
    expect(response_cookies['t'][0].length > 100).to be(true)
  end

  it "doesnt change an existing 't' or 'uid' permacookie"
  # do
  #   get("/api/v2/token")
  #   expect(response.status).to eq(200)

  #   response_cookies1 = CGI::Cookie::parse(response.headers['Set-Cookie'])
  #   token1 = response_cookies1['t'].first

  #   get("/api/v2/token")

  #   response_cookies2 = CGI::Cookie::parse(response.headers['Set-Cookie'])
  #   token2 = response_cookies2['t'].first

  #   expect(token1).to eq(token2)
  # end

  it "gets the stream-topshelf XHR" do
    get("/api/v1/stream-topshelf")
    data = JSON.parse(response.body)

    expect(response.status).to eq(200)
    expect(data.keys).to eq(['v1'])
    expect(data['v1'].keys).to eq(["records", "quickreads", "facebook", "openingstatement"])
  end

end
