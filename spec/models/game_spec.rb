require "spec_helper"
feature "User sees the show page for games" do

  scenario "starting a game" do
    User.create(first_name: "Jackie", email: "j@mail.com", password: "apples")
    Game.create(name: "poro122")
    Gameplayer.create(team: "black", user_id: User.first.id, game_id: Game.first.id)

    visit "/"
    click_link("poro122")
    fill_in 'Email', with: "j@mail.com"
    fill_in 'Password', with: 'apples'
    click_button "Log in"

    expect(page).to have_content("Signed in successfully")
  end
end

describe Game do
  it { should have_valid(:name).when("Test") }
  it { should_not have_valid(:name).when(nil, "")}

  it { should have_many :gameplayers}
  it { should have_many :users}
end
