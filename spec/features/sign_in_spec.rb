require 'rails_helper'
feature 'Sign up', %(
  As an unauthenticated user, i want to sign up so that I can create a game.
) do
  scenario 'specifying valid and required information' do
    visit root_path
    click_link 'Sign up'
    fill_in 'First name', with: 'Jackie'
    fill_in 'Email', with: 'user@gmail.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign up'

    expect(page).to have_content("Create a new game")
    expect(page).to have_content("Sign Out")
  end
end
