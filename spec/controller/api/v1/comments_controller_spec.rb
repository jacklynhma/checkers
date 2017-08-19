require "rails_helper"
require 'byebug'
require 'devise'

RSpec.describe Api::V1::CommentsController, type: :controller do
let!(:first_game) { Game.create(name: "testing" )}
let!(:first_user) { User.create(first_name: "jackie", email: "jackie@gmail.com", password: "apples")}
let!(:second_user) { User.create(first_name: "poro", email: "poro@testmail.com", password: "apples")}
let!(:first_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: first_game.id )}
let!(:sec_match) { Gameplayer.create(team: "red", user_id: second_user.id, game_id: first_game.id )}
let!(:first_comment) {Comment.create(body: "hi!", user_id: first_user.id, game_id: first_game.id)}
let!(:second_comment) {Comment.create(body: "GG!", user_id: second_user.id, game_id: first_game.id)}

  describe "GET#index" do
    # return a list of games
    # need to have a user to sign in
    # sign_in_as etc etc
    it "shows a list of the comments" do
      get :index, params: {game_id: first_game.id}

      expect(response.status).to eq 200
      expect(User.first.comments[0].body).to eq("hi!")
      expect(User.last.comments[0].body).to eq("GG!")
    end
    it "contains the list of user names" do
      get :index, params: {game_id: first_game.id}

      expect(Game.first.users[0].first_name).to eq("jackie")
      expect(Game.first.users.last.first_name).to eq("poro")
    end
    it "contains the list of teams" do
      get :index, params: {game_id: first_game.id}

      expect(Game.first.team_players[0][0].first_name).to eq("jackie")
      expect(Game.first.team_players[1][0].first_name).to eq("poro")
    end
  end

  describe "POST#Create" do
    it "makes a new comment" do
      sign_in first_user
      post :create, params: {game_id: first_game.id, id: 3, body: "testing",
        comment: {body: "testing"}}

      expect(first_game.comments.last.body).to eq("testing")
      expect(first_game.comments.last.user.first_name).to eq("jackie")
    end
  end
end
