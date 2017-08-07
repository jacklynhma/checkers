require 'spec_helper'

feature "User sees the show page for games" do
  let!(:newuser) do
    User.create( first_name: "Jackie", email: "j@mail.com", password: "apples"  )
  end
  let!(:game) do
    Game.create( name: "poro121" )
  end
  let!(:gameshow) do
    Gameplayer.create(team: "black", user_id: User.first.id, game_id: Game.first.id )
  end


  scenario "redirect game since user is not logged in " do
    visit "/"
    click_link("poro121")
    fill_in 'Email', with: "j@mail.com"
    fill_in 'Password', with: 'apples'
    click_button "Log in"

    expect(page).to have_content("Signed in successfully")
  end
end
