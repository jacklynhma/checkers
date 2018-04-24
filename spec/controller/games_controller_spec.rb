require "rails_helper"
require 'byebug'
require 'devise'

RSpec.describe GamesController, type: :controller do
let(:first_game) { Game.create(name: "testing" )}
let!(:first_user) { User.create(first_name: "jackie", email: "jackie@gmail.com", password: "apples")}
let!(:third_user) { User.create(first_name: "harry", email: "harry@nyc.com", password: "apples")}

  describe "GET#Index" do
    # return a list of games
    it "should return a list of games" do
      get :index

      expect(response).to render_template("index")
      expect(response.status).to eq 200

      # see if you can see first game on the page
    end
  end

  describe "POST#join" do
    # return a list of games
    it "should rediret to the game show page" do
      sign_in first_user
      post :join, params: { id: first_game.id }

      expect(response.status).to eq 302
      expect(first_game.gameplayers[0].user.first_name).to eq("jackie")
      expect(first_game.gameplayers[0].team).to eq("black")
    end
    let!(:sec_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: first_game.id )}
    it "should rediret to the game show page" do
      sign_in third_user
      post :join, params: {id: first_game.id}

      expect(response.status).to eq 302
      expect(first_game.gameplayers[1].user.first_name).to eq("harry")
      expect(first_game.gameplayers[1].team).to eq("red")
    end
  end
  describe "Post#resign" do
    # return a list of games
    let!(:sec_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: first_game.id )}
    it "should rediret to the game show page" do
      sign_in first_user
      post :resign, params: { id: first_game.id }

      expect(response.status).to eq 302
      expect(first_game.gameplayers).to eq([])
    end
  end
  describe "Post#create" do
    it "should create a game" do
      sign_in first_user
      post :create, params: { game: { name: "testingtest" } }

      expect(response.status).to eq 302
      expect(Game.last.name).to eq("testingtest")
    end

    it "should render a 200 status since the name is not entered" do
      sign_in first_user
      post :create, params: { game: { name: "" } }

      expect(response.status).to eq 200
      expect(response.content_type).to eq "text/html"
    end
  end
end
