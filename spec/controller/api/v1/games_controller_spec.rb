require "rails_helper"
require 'byebug'
require 'devise'

RSpec.describe Api::V1::GamesController, type: :controller do
let!(:first_game) { Game.create(name: "testing" )}
let!(:first_user) { User.create(first_name: "jackie", email: "jackie@gmail.com", password: "apples")}
let!(:first_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: first_game.id )}


  describe "GET#show" do
    # return a list of games
    # need to have a user to sign in
    # sign_in_as etc etc
    it "show the game" do
      get :show, params: {id: first_game.id}

      expect(response.status).to eq 200
      expect(first_user.gameplayers.find_by(game_id: first_game.id).team).to eq("black")
    end
  end

  describe "PUT#update" do
    it "update game with new move " do
      sign_in first_user

      put :update, params: {id: first_game.id, coordinates: [2, 1, 3, 2]}, as: :json


      expect(first_game.reload.state_of_piece[3][2]).to eq "B"
    end

    it "fail to update" do
      sign_in first_user
      put :update, params: {id: first_game.id, coordinates: [1, 0, 2, 2]}, as: :json

      expect(response.status).to eq 200
      expect(first_game.reload.state_of_piece[2][2]).to eq nil
    end
    context "must eat a piece" do
      let!(:second_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: second_game.id )}
      let!(:second_game) {Game.create({name: "testing", state_of_piece:
        [[nil, "B", nil, "B", nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, nil, nil, "B", nil, "B", nil, "B"],
        [nil, nil, "B", nil, nil, nil, nil, nil],
        [nil, nil, nil, "R", nil, nil, nil, nil],
        ["R", nil, "R", nil, nil, nil, "R", nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "should fail to update" do
        sign_in first_user
        put :update, params: {id: second_game.id, coordinates: [3, 2, 4, 1]}, as: :json

        expect(second_game.reload.state_of_piece[4][1]).to eq nil
        expect(second_game.reload.state_of_piece[3][2]).to eq "B"
      end
    end
    context "must eat a piece" do
      let!(:third_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", state_of_piece:
        [[nil, "B", nil, "B", nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, nil, nil, "B", nil, "B", nil, "B"],
        [nil, nil, "B", nil, nil, nil, nil, nil],
        [nil, nil, nil, "R", nil, nil, nil, nil],
        ["R", nil, "R", nil, nil, nil, "R", nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "should be able to eat the opposing piece next to it" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [3, 2, 5, 4]}, as: :json

        expect(third_game.reload.state_of_piece[3][2]).to eq nil
        expect(third_game.reload.state_of_piece[5][4]).to eq "B"
        expect(third_game.reload.state_of_piece[4][3]).to eq nil
      end
    end
    context "R should not be allowed to move because it is not his turn" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 1, state_of_piece:
        [[nil, "B", nil, "B", nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, "B", nil, nil, nil, "B", nil, nil],
        [nil, nil, nil, nil, "B", nil, "B", nil],
        [nil, nil, nil, "R", nil, nil, nil, nil],
        ["R", nil, "R", nil, nil, nil, "R", nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "nothing should happen" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [4, 3, 3, 2]}, as: :json


        expect(third_game.reload.state_of_piece[3][2]).to eq nil
        expect(third_game.reload.state_of_piece[4][3]).to eq "R"
      end
    end
    context "R piece should not be forced to eat B piece since space after jump is not nil" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:
        [[nil, "B", nil, "B", nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, "B", nil, nil, nil, "B", nil, nil],
        [nil, nil, nil, nil, "B", nil, "B", nil],
        [nil, nil, nil, "R", nil, nil, nil, nil],
        ["R", nil, "R", nil, nil, nil, "R", nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "R should not be forced to eat B " do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [4, 3, 3, 2]}, as: :json


        expect(third_game.reload.state_of_piece[3][2]).to eq "R"
        expect(third_game.reload.state_of_piece[4][3]).to eq nil
      end
    end

    context "B piece should not be forced to eat B piece since space after jump is off the board" do
      let!(:third_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 1, state_of_piece:
        [[nil, "B", nil, "B", nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, "B", nil, nil, nil, "B", nil, nil],
        [nil, nil, nil, nil, "B", nil, "B", nil],
        [nil, nil, nil, "R", nil, nil, nil, nil],
        ["R", nil, "R", nil, nil, nil, "B", nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "B should not be forced to eat R " do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [3, 6, 4, 7]}, as: :json


        expect(third_game.reload.state_of_piece[3][6]).to eq nil
        expect(third_game.reload.state_of_piece[4][7]).to eq "B"
      end
    end

    context "R piece can jump twice if there is an opposing piece next to it and there is an empty space" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:
        [[nil, "B", nil, nil, nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, nil, nil, nil, nil, "B", nil, nil],
        [nil, nil, "B", nil, "R", nil, "B", nil],
        [nil, "R", nil, "R", nil, nil, nil, nil],
        ["R", nil, nil, nil, nil, nil, nil, nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "if required move is not null then the turn should be the same" do
        sign_in first_user

        put :update, params: {id: third_game.id, coordinates: [4, 3, 2, 1]}, as: :json



        expect(third_game.reload.state_of_piece[4][3]).to eq nil
        expect(third_game.reload.state_of_piece[2][1]).to eq "R"
        expect(third_game.reload.state_of_piece[3][2]).to eq nil
        expect(third_game.reload.turn).to eq 2
      end
    end
    context "R should become RK" do

      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:

        [[nil, "B", nil, nil, nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, "R", nil, nil, nil, "B", nil, nil],
        [nil, nil, nil, nil, "R", nil, "B", nil],
        [nil, "R", nil, nil, nil, nil, nil, nil],
        ["R", nil, nil, nil, nil, nil, nil, nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "should keep the state of the previous update and allow it to jump again" do
        sign_in first_user
        put :update, params: {id: third_game.id, turn: 2, coordinates: [2, 1, 0, 3]}, as: :json
        expect(third_game.reload.state_of_piece[2][1]).to eq nil
        expect(third_game.reload.state_of_piece[0][3]).to eq "RK"
      end
    end
    context "when a piece reaches the opposing side, they will turn into a BK" do
      let!(:third_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 1, state_of_piece:
        [[nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, "R", nil , nil, nil],
        [nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "B"],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, "R", nil, "R", nil, "B", nil, "R"],
        ["R", nil, "R", nil, nil, nil, "R", nil]]
        })
      }
      it "B should turn into Bk" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [6, 5, 7, 4]}, as: :json


        expect(third_game.reload.state_of_piece[6][5]).to eq nil
        expect(third_game.reload.state_of_piece[7][4]).to eq "BK"
      end
    end
    context "when B tries to step on R, it will not be a valid move" do
      let!(:third_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 1, state_of_piece:
        [[nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, "R", nil , nil, nil],
        [nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "B"],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, "R", nil, "R", nil, "B", nil, "R"],
        ["R", nil, "R", nil, nil, nil, "R", nil]]
        })
      }
      it "the board should remain the same" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [6, 5, 7, 6]}, as: :json


        expect(third_game.reload.state_of_piece[6][5]).to eq "B"
        expect(third_game.reload.state_of_piece[7][6]).to eq "R"
      end
    end
    context "when R tries to step on B, it will not be a valid move" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:
        [[nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, "R", nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, "B"],
        [nil, nil, nil, nil, "B", nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "B"],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, "R", nil, "R", nil, "B", nil, "R"],
        ["R", nil, "R", nil, nil, nil, "R", nil]]
        })
      }
      it "the board should remain the same" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [4, 3, 3, 4]}, as: :json


        expect(third_game.reload.state_of_piece[4][3]).to eq "R"
        expect(third_game.reload.state_of_piece[3][4]).to eq "B"
      end
    end
    context "when B tries to step on R, it will not be a valid move" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 1, state_of_piece:
        [[nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, "R", nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, "B"],
        [nil, nil, nil, nil, "B", nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "B"],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, "R", nil, "B", nil, "B", nil, "R"],
        ["R", nil, "R", nil, nil, nil, "R", nil]]
        })
      }
      it "the board should remain the same" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [6, 3, 7, 2]}, as: :json


        expect(third_game.reload.state_of_piece[6][3]).to eq "B"
        expect(third_game.reload.state_of_piece[7][2]).to eq "R"
      end
    end
    context "When r moves next to B, their turn should end" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:
        [[nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, "R", nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, "B"],
        [nil, nil, nil, nil, "B", nil, nil, nil],
        [nil, nil, nil, nil, nil, "B", nil, "B"],
        [nil, nil, "R", nil, "B", nil, nil, nil],
        [nil, "R", nil, "R", nil, "B", nil, "R"],
        ["R", nil, "R", nil, nil, nil, "R", nil]]
        })
      }
      it "the board should remain the same" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [5, 2, 4, 3]}, as: :json


        expect(third_game.reload.state_of_piece[5][2]).to eq nil
        expect(third_game.reload.state_of_piece[4][3]).to eq "R"
        expect(third_game.reload.turn).to eq 3
      end
    end
    context "When r moves next to B, their turn should end" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:
        [[nil, "B", nil, "B", nil, "B", nil, "B"],
        ["B", nil, "B", nil, "B", nil , "B", nil],
        [nil, nil, nil, "B", nil, "B", nil, "B"],
        [nil, nil, "B", nil, nil, nil, "B", nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        ["R", nil, "R", nil, "R", nil, "R", nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, nil, nil, "R", nil]]
        })
      }
      it "the board should remain the same" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [5, 4, 4, 3]}, as: :json


        expect(third_game.reload.state_of_piece[5][4]).to eq nil
        expect(third_game.reload.state_of_piece[4][3]).to eq "R"
        expect(third_game.reload.turn).to eq 3
      end
    end
    context "When B moves next to R, their turn should end" do
      let!(:third_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 1, state_of_piece:
        [[nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, "R", nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, "B"],
        [nil, nil, nil, nil, "B", nil, nil, nil],
        [nil, nil, nil, nil, nil, "B", nil, "B"],
        [nil, nil, "R", nil, "B", nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "R"],
        ["R", nil, "R", nil, nil, nil, "R", nil]]
        })
      }
      it "the turn should remain the same" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [3, 4, 4, 3]}, as: :json


        expect(third_game.reload.state_of_piece[3][4]).to eq nil
        expect(third_game.reload.state_of_piece[4][3]).to eq "B"
        expect(third_game.reload.turn).to eq 2
      end
    end
    context "when a piece reaches the opposing side, they will turn into a RK, which allows them to move backwards " do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:
        [[nil, "B", nil, "RK", nil, "B", nil, "B"],
        [nil, nil, "B", nil, nil, nil , nil, nil],
        [nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, nil, nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "B"],
        [nil, nil, nil, nil, "B", nil, nil, nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "RK should move backwards" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [0, 3, 1, 4]}, as: :json


        expect(third_game.reload.state_of_piece[0][3]).to eq nil
        expect(third_game.reload.state_of_piece[1][4]).to eq "RK"
      end
    end
    context "Since RK can move backwards it should be allowed to jump the opposing piece" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", turn: 2, state_of_piece:
        [[nil, "B", nil, "RK", nil, "B", nil, "B"],
        [nil, nil, "B", nil, nil, nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, nil, nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "B"],
        [nil, nil, nil, nil, "B", nil, nil, nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "RK should move backwards" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinates: [0, 3, 2, 1]}, as: :json


        expect(third_game.reload.state_of_piece[0][3]).to eq nil
        expect(third_game.reload.state_of_piece[2][1]).to eq "RK"
      end
    end
    context "team_misisng_piece should return team black" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", state_of_piece:
        [[nil, nil, nil, nil, nil, nil, "BK", nil],
        [nil, nil, nil, nil, nil, nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, "BK", nil],
        [nil, nil, nil, nil, nil, "B", nil, "B"],
        [nil, nil, nil, nil, nil, nil, "B", nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        ["BK", nil, nil, nil, nil, nil, "B", nil],
        [nil, nil, nil, nil, nil, "B", nil, "B"]]
        })
      }
      it "there should be two black piece eatten" do
        sign_in first_user
        put :show, params: {id: third_game.id}
        expect(response.status).to eq 200
        expect(third_game.reload.team_missing_piece).to eq "team red"
      end
    end
  end
end
