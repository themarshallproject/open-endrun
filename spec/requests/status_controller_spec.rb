require 'rails_helper'

RSpec.describe StatusController, type: :request do

  it "should have a 200 status code for /_status" do
    # this tests redis, memcached, postgres and elasticsearch
    get "/_status"
    expect(response.status).to eq(200)
  end

  it "should fail if postgres is poisoned"

end
