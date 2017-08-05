require "rails_helper"
require 'byebug'
require 'devise'

RSpec.describe GamesController, type: :controller do
let(:first_game) { Game.create(name: "testing" )}
let!(:first_user) { User.create(first_name: "jackie", email: "jackie@gmail.com", password: "apples")}
let!(:first_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: first_game.id )}

  describe "GET#Index" do
    # return a list of games
    it "should return a list of games" do
      get :index

      expect(response).to render_template("index")
      expect(response.status).to eq 200

      # see if you can see first game on the page
    end
  end
end
