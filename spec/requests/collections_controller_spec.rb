require 'rails_helper'

RSpec.describe CollectionsController, type: :feature do

  before :each do
    @user = create(:user)
    visit "/login"
    fill_in :email, with: @user.email
    fill_in :password, with: @user.password
    click_button "Log In"
  end

  it "redirects to the canoncial url", js: true do
    tag = create(:tag, name: "my tag name")
    expect(tag.slug).to eq("my-tag-name")
    expect(tag.to_param).to eq("#{tag.id}-my-tag-name")

    visit collections_show_path("#{tag.id}-my")
    expect(current_path).to eq(collections_show_path(tag.to_param))
  end

  describe "GET #index" do
    it "returns http success"
    # do
      # get :index
      # expect(response).to have_http_status(:success)
    # end
  end

  describe "GET #show" do
    it "returns http success"
    # do
      # get :show
      # expect(response).to have_http_status(:success)
    # end
  end

  describe "GET #api_v1_items" do
    it "returns http success"
    # do
      # get :api_v1_items
      # expect(response).to have_http_status(:success)
    # end
  end

end
