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


  describe "GET#edit" do
    # return a list of games
    it "require login" do
      get :edit, params: {id: first_game.id}

      expect(response).to redirect_to user_session_path
      # see if you can see first game on the page
    end

    it "allow to edit game since user is logged in" do
      sign_in first_user
      get :edit, params: {id: first_game.id}

      expect(response.status).to eq 200
      # see if you can see first game on the page
    end
  end

  describe "GET#show" do
    # return a list of games
    # need to have a user to sign in
    # sign_in_as etc etc
    it "show the game" do
      get :show, params: {id: first_game.id}

      expect(response).to render_template("show")
      expect(response.status).to eq 200
      expect(first_user.gameplayers.find_by(game_id: first_game.id).team).to eq("black")
    end
  end

  describe "PUT#update" do
    it "update game with new move " do
      sign_in first_user

      put :update, params: {id: first_game.id, coordinate: {from: "[2,1]", to: "[3,2]"}}

      expect(response).to redirect_to(first_game)
      expect(first_game.reload.state_of_piece[3][2]).to eq "B"
    end
    it "fail to update" do
      sign_in first_user
      put :update, params: {id: first_game.id, coordinate: {from: "[1,0]", to: "[2,2]"}}

      expect(response.status).to eq 302
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
        put :update, params: {id: second_game.id, coordinate: {from: "[3,2]", to: "[4,1]"}}

        expect(response).to redirect_to(second_game)
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
      it "should eat the opposing piece next to it" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinate: {from: "[3,2]", to: "[5,4]"}}

        expect(response).to redirect_to(third_game)
        expect(third_game.reload.state_of_piece[3][2]).to eq nil
        expect(third_game.reload.state_of_piece[5][4]).to eq "B"
        expect(third_game.reload.state_of_piece[4][3]).to eq nil
      end
    end
    context "R piece should not be forced to eat B piece since space after jump is not nil" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", state_of_piece:
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
      it "all the piece should remain the same" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinate: {from: "[4,3]", to: "[2,5]"}}

        expect(response).to redirect_to(third_game)
        expect(third_game.reload.state_of_piece[4][3]).to eq "R"
        expect(third_game.reload.state_of_piece[2][5]).to eq "B"
        expect(third_game.reload.state_of_piece[3][4]).to eq "B"
      end
    end
    context "R piece should allowed to move piece to the left" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", state_of_piece:
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
      it "R is allowed to move to the left" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinate: {from: "[4,3]", to: "[3,2]"}}

        expect(response).to redirect_to(third_game)
        expect(third_game.reload.state_of_piece[4][3]).to eq nil
        expect(third_game.reload.state_of_piece[3][2]).to eq "R"
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
      it "there should be two black piece eatten" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinate: {from: "[4,3]", to: "[2,1]"}}
        expect(response).to redirect_to(third_game)

        expect(third_game.reload.state_of_piece[2][1]).to eq "R"
        expect(third_game.reload.state_of_piece[4][3]).to eq nil
        expect(third_game.reload.state_of_piece[3][2]).to eq nil

        put :update, params: {id: third_game.id, coordinate: {from: "[2,1]", to: "[0,3]"}}

        expect(response).to redirect_to(third_game)
        expect(third_game.reload.state_of_piece[1][2]).to eq nil
        expect(third_game.reload.state_of_piece[0][3]).to eq "RK"
      end
    end
    context "when a piece reaches the opposing side, they will turn into a RK" do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", state_of_piece:
        [[nil, "B", nil, nil, nil, "B", nil, "B"],
        [nil, nil, "B", nil, "R", nil , nil, nil],
        [nil, "B", nil, nil, nil, nil, nil, "B"],
        [nil, nil, "B", nil, nil, nil, nil, nil],
        [nil, nil, nil, "R", nil, "B", nil, "B"],
        [nil, nil, nil, nil, "B", nil, nil, nil],
        [nil, "R", nil, "R", nil, "R", nil, "R"],
        ["R", nil, "R", nil, "R", nil, "R", nil]]
        })
      }
      it "R should turn into rk" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinate: {from: "[1,4]", to: "[0,3]"}}

        expect(response).to redirect_to(third_game)
        expect(third_game.reload.state_of_piece[1][4]).to eq nil
        expect(third_game.reload.state_of_piece[0][3]).to eq "RK"
      end
    end
    context "when a piece reaches the opposing side, they will turn into a RK, which allows them to move backwards " do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", state_of_piece:
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
      it "RK should move backards" do
        sign_in first_user
        put :update, params: {id: third_game.id, coordinate: {from: "[0,3]", to: "[1,4]"}}

        expect(response).to redirect_to(third_game)
        expect(third_game.reload.state_of_piece[1][3]).to eq nil
        expect(third_game.reload.state_of_piece[1][4]).to eq "RK"
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

        expect(response).to render_template("show")
        expect(response.status).to eq 200
        expect(third_game.reload.team_missing_piece).to eq "team red"
      end
    end
    context "the opposing person when there are no more moves left winner is black" do
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
      it "black should be declared the winner" do
        sign_in first_user
        put :show, params: {id: third_game.id}

        expect(response).to render_template("show")
        expect(response.status).to eq 200
        expect(third_game.reload.winner).to eq "Team Black Wins!"
      end
    end
    context "R can no longer move so Black wins " do
      let!(:third_match) { Gameplayer.create(team: "red", user_id: first_user.id, game_id: third_game.id )}
      let!(:third_game) {Game.create({name: "testing", state_of_piece:
        [[nil, nil, nil, nil, nil, nil, "BK", nil],
        [nil, nil, nil, nil, nil, nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, "BK", nil],
        [nil, nil, nil, nil, nil, "B", "B", "B"],
        [nil, nil, nil, nil, nil, nil, "B", "R"],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        ["BK", nil, nil, nil, nil, nil, "B", nil],
        [nil, nil, nil, nil, nil, "B", nil, "B"]]
        })
      }
      it "there should be two black piece eatten" do
        sign_in first_user
        put :show, params: {id: third_game.id}

        expect(response).to render_template("show")
        expect(response.status).to eq 200
        expect(third_game.reload.winner).to eq "Team Black Wins!"
      end
    end
  end
end
