require "spec_helper"

describe "user sign in" do
  it "allows users to sign in after they have registered" do
    user = User.new(:email    => "alindeman@example.com",
                       :password => "ilovegrapes")
    user.save! validate: false

    visit "/users/sign_in"

    fill_in "Email",    :with => "alindeman@example.com"
    fill_in "Password", :with => "ilovegrapes"

    click_button "Log in"

    page.should have_content("Signed in successfully.")
  end
end