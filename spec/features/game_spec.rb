require 'spec_helper'

feature "User sees the show page for games" do
  let!(:newuser) {User.create(first_name: "Jackie", email: "j@mail.com", password: "apples")}
  let!(:game) {Game.create( name: "poro121" )}
  let!(:gameshow) {Gameplayer.create(team: "black", user_id: User.first.id, game_id: Game.first.id )}

  scenario "creating a game " do
   visit root_path
   click_link 'Sign In'
   fill_in 'Email', with: 'j@mail.com'
   fill_in 'Password', with: 'apples'
   click_button 'Log in'
   fill_in 'Title', with: "Testing"
   click_button "Create Game"

   expect(page).to have_content("Team Checkers")
 end
end
