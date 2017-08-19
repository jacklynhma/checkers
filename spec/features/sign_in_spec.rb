require 'rails_helper'
feature 'Sign up', %(
  As an unauthenticated user, i want to sign up so that I can create a game.
) do
  let!(:first_user) { User.create(first_name: "jackie", email: "jackie@gmail.com", password: "apples")}

  scenario 'specifying valid and required information' do
    visit root_path
    click_link 'Sign up'
    fill_in 'First name', with: 'Jackie'
    fill_in 'Email', with: 'user@gmail.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign up'

    expect(page).to have_content("Sign Out")
  end

  scenario 'specifying valid and required information' do
    visit root_path
    click_link 'Sign up'
    fill_in 'First name', with: 'Jackie'
    fill_in 'Email', with: 'user@gmail.com'
    click_button 'Sign up'

    expect(page).to have_content("Password can't be blank")
  end

  scenario 'specifying valid and required information' do
    visit root_path
    click_link 'Sign up'
    fill_in 'First name', with: 'Jackie'
    click_button 'Sign up'

    expect(page).to have_content("Email can't be blank")
  end

  scenario 'specifying valid and required information' do
    visit root_path
    click_link 'Sign up'
    click_button 'Sign up'

    expect(page).to have_content("First name can't be blank")
  end

  scenario 'able to sign in' do
    visit root_path
    click_link 'Sign In'
    fill_in 'Email', with: 'jackie@gmail.com'
    fill_in 'Password', with: 'apples'
    click_button 'Log in'

    expect(page).to have_content("Signed in successfully.")
  end
end
