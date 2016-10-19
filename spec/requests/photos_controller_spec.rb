require 'rails_helper'

RSpec.describe PhotosController, type: :feature do

  before :each do
    @user = create(:user)
    visit "/login"
    fill_in :email, with: @user.email
    fill_in :password, with: @user.password
    click_button "Log In"
  end

  it 'has an index', js: true do
    visit "/admin/photos"
    expect(page.body).to include("Photos")
  end

end