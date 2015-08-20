require 'rails_helper'

describe "home page" do

  it "listing all" do
    visit root_path
    page.should have_content("Welcome to Forem!")
    page.should have_content("A placeholder forum.")

  end

end