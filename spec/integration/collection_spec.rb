require 'rails_helper'

RSpec.describe "Collections", type: :request do

  it 'gets a success code on the homepage' do
    get collections_index_path
    expect(response.status).to eq(200)
  end

  it 'gets a success code for a tag page' do
    tag = create(:tag, name: "My Tag!")
    get collections_show_path(tag)
    expect(response.status).to eq(200)
  end

  it 'maintains the redirect from pre-launch' do
    get '/records/caeffd2d6817a626c0a275e5707'
    expect(response).to redirect_to(collections_index_path)
  end

end
