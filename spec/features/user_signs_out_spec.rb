require "rails_helper"

feature "User signs in to existing account" do
  let!(:newuser) do
    User.create(
      first_name: "joeshmoe",
      email: "joeshmoe@gmail.com",
      password: "joe1234",
      password_confirmation: "joe1234"
    )
  end

  scenario "user supplies valid and required sign-in information" do
    visit new_user_session_path
    fill_in 'Email', with: "joeshmoe@gmail.com"
    fill_in 'Password', with: "joe1234"

    click_button "Log in"

    click_link "Sign Out"

    expect(page).to have_content "Sign In"
  end

end
