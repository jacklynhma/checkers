
require "rails_helper"

describe Game do
  it { should have_valid(:name).when("Test") }
  it { should_not have_valid(:name).when(nil, "") }

  it { should have_many :gameplayers}
  it { should have_many :users}
end

describe "#set_board" do
  context "a set of history of pieces was given. a player clicks the replay button" do
    let (:game) do
      Game.new({name: "bear",
         state_of_piece:
          [[nil, "B", nil, "B", nil, "B", nil, "B"],
           ["B", nil, "B", nil, nil, nil, "B", nil],
           [nil, nil, nil, "B", nil, "B", nil, nil],
           [nil, nil, nil, nil, nil, nil, "B", nil],
           [nil, nil, nil, nil, nil, nil, nil, nil],
           ["R", nil, nil, nil, "R", nil, "R", nil],
           [nil, "B", nil, nil, nil, "R", nil, "R"],
           ["R", nil, "R", nil, "R", nil, "R", nil]],
         history_of_pieces:
          [[2, 3, 3, 4],
           [5, 2, 4, 3],
           [3, 4, 5, 2],
           [6, 1, 4, 3],
           [2, 7, 3, 6],
           [6, 3, 5, 2],
           [1, 4, 2, 3],
           [4, 3, 3, 2],
           [2, 1, 4, 3],
           [4, 3, 6, 1]],
         turn: 10
      })
    end
    it "looks like turn 0" do
      expect(game.set_board(0)).to eq [
    [nil, "B", nil, "B", nil, "B", nil, "B"],
   ["B", nil, "B", nil, "B", nil, "B", nil],
   [nil, "B", nil, "B", nil, "B", nil, "B"],
   [nil, nil, nil, nil, nil, nil, nil, nil],
   [nil, nil, nil, nil, nil, nil, nil, nil],
   ["R", nil, "R", nil, "R", nil, "R", nil],
   [nil, "R", nil, "R", nil, "R", nil, "R"],
   ["R", nil, "R", nil, "R", nil, "R", nil]]
    end
    it "looks like turn 1" do
      expect(game.set_board(1)).to eq [
   [nil, "B", nil, "B", nil, "B", nil, "B"],
   ["B", nil, "B", nil, "B", nil, "B", nil],
   [nil, "B", nil, nil, nil, "B", nil, "B"],
   [nil, nil, nil, nil, "B", nil, nil, nil],
   [nil, nil, nil, nil, nil, nil, nil, nil],
   ["R", nil, "R", nil, "R", nil, "R", nil],
   [nil, "R", nil, "R", nil, "R", nil, "R"],
   ["R", nil, "R", nil, "R", nil, "R", nil]]
    end
    it "looks like turn 9" do
      expect(game.set_board(10)).to eq [
    [nil, "B", nil, "B", nil, "B", nil, "B"],
   ["B", nil, "B", nil, nil, nil, "B", nil],
   [nil, nil, nil, "B", nil, "B", nil, nil],
   [nil, nil, nil, nil, nil, nil, "B", nil],
   [nil, nil, nil, nil, nil, nil, nil, nil],
   ["R", nil, nil, nil, "R", nil, "R", nil],
   [nil, "B", nil, nil, nil, "R", nil, "R"],
   ["R", nil, "R", nil, "R", nil, "R", nil]]
    end
  end
end

describe "#playing?" do
  let!(:games1) {Game.create(name: "jackie" )}
  let!(:first_user) { User.create(first_name: "jackie", email: "jackie@gmail.com", password: "apples")}
  let!(:first_match) { Gameplayer.create(team: "black", user_id: first_user.id, game_id: games1.id )}
  let!(:second_user) { User.create(first_name: "poro", email: "poro@fire.com", password: "apples")}

  it "returns true if the user is included in the game " do
    expect(games1.playing?(first_user)).to eq true
    expect(games1.playing?(second_user)).to eq false
  end
end

describe "#starting_board"do
  let!(:games1) {Game.create(name: "jackie" )}
  it "return starting board " do
    expect(games1.starting_board).to eq [
      [nil, "B", nil, "B", nil, "B", nil, "B"],
      ["B", nil, "B", nil, "B", nil , "B", nil],
      [nil, "B", nil, "B", nil, "B", nil, "B"],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      ["R", nil, "R", nil, "R", nil, "R", nil],
      [nil, "R", nil, "R", nil, "R", nil, "R"],
      ["R", nil, "R", nil, "R", nil, "R", nil]
    ]
  end
end

describe "#after_intialize #setup_game" do
  let!(:games1) {Game.create(name: "jackie", state_of_piece: "")}
  it "returns the starting board " do

    expect(games1.state_of_piece).to eq [
    [nil, "B", nil, "B", nil, "B", nil, "B"],
    ["B", nil, "B", nil, "B", nil , "B", nil],
    [nil, "B", nil, "B", nil, "B", nil, "B"],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    ["R", nil, "R", nil, "R", nil, "R", nil],
    [nil, "R", nil, "R", nil, "R", nil, "R"],
    ["R", nil, "R", nil, "R", nil, "R", nil]
    ]
    expect(games1.history_of_pieces).to eq []
  end
end

describe "#winner" do
  context "red has no more pieces" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
        [[nil, nil, nil, nil, nil, nil, "BK", nil],
        [nil, nil, nil, nil, nil, nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, "BK", nil],
        [nil, nil, nil, nil, nil, "B", nil, "B"],
        [nil, nil, nil, nil, nil, nil, "B", nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        ["BK", nil, nil, nil, nil, nil, "B", nil],
        [nil, nil, nil, nil, nil, "B", nil, "B"]]
        })
    end
    it "returns black team" do
      expect(game.winner).to eq("Team Black Wins!")
    end
  end
  context "black has no more pieces" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
        [[nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil , nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, "R", nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]]
        })
    end
    it "returns black team" do
      expect(game.winner).to eq("Team Red Wins!")
    end
  end
  context "R can no longer move so Black wins " do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, "BK", nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, "BK", nil],
      [nil, nil, nil, nil, nil, "B", nil, "B"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, nil, nil, "R"],
      ["BK", nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "B", nil, "B"]]
      })
    end
    it "team black wins" do
      expect(game.winner).to eq "Team Black Wins!"
    end
  end
  context "B can no longer move so Red wins " do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "team black wins" do
      expect(game.winner).to eq "Team Red Wins!"
    end
  end
end

describe "#not_your_turn" do
  context "return true since user is on team black" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    let (:firstplayer) do
      User.new({first_name: "jackie", email: "jackie@mail.com", password: "apples"})
    end
    let (:gameplay) do
      Gameplayer.new({team: "black", user_id: User.first.id, game_id: Game.first.id})
    end


    it "will return true" do
      expect(game.not_your_turn("black", 1)).to eq false
    end
  end
  context "return true since user is on team black" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    let (:firstplayer) do
      User.new({first_name: "jackie", email: "jackie@mail.com", password: "apples"})
    end
    let (:gameplay) do
      Gameplayer.new({team: "black", user_id: User.first.id, game_id: Game.first.id})
    end


    it "will return true" do
      expect(game.not_your_turn("red", 1)).to eq true
    end
  end
end

describe "#not_your_piece" do
  context "black team tries to click on a red piece, which will return true" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return true" do
      expect(game.not_your_piece("black", "R")).to eq true
    end
  end
  context "red team tries to click on a black piece, which will return true" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return true" do
      expect(game.not_your_piece("red", "B")).to eq true
    end
  end
  context "red team tries to click on a red piece, which will return false" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return true" do
      expect(game.not_your_piece("red", "R")).to eq false
    end
  end
  context "black team tries to click on a black piece, which will return false" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return true" do
      expect(game.not_your_piece("black", "B")).to eq false
    end
  end
end

describe "#off_the_board" do
  context "given the coordinates, it wil return false since it is on the board" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return false" do
      expect(game.off_the_board(3, 4)).to eq false
    end
  end
  context "given the coordinates, it wil return true since it is off the board" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return false" do
      expect(game.off_the_board(8, 4)).to eq true
    end
  end
end

describe "#piece_must_moved" do
  context "given the coordinates a piece must eat another piece" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return false" do
      expect(game.piece_must_moved("black", [0, 1], [1, 2])).to eq true
    end
  end

  context "given the coordinates a piece must eat another piece" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return false" do
      expect(game.piece_must_moved("red", [3, 6], [2, 7])).to eq true
    end
  end
  context "given the coordinates a piece can eat another piece" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return false" do
      expect(game.piece_must_moved("red", [4, 4], [2, 6])).to eq false
    end
  end
  context "given the coordinates a piece can eat another piece" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return false" do
      expect(game.piece_must_moved("black", [3, 5], [5, 3])).to eq false
    end
  end
end

describe "#valid_R_move" do
  context "if there are no jumps avaiable, method will return true if it is a valid move" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return true" do
      expect(game.valid_R_move(2, 4, 1, 3)).to eq true
    end
    it "will return false" do
      expect(game.valid_R_move(2, 4, 2, 3)).to eq false
    end
  end
end


describe "#valid_B_move" do
  context "if there are no jumps avaiable, method will return true if it is a valid move" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return true" do
      expect(game.valid_B_move(0, 2, 1, 3)).to eq true
    end

    it "will return false" do
      expect(game.valid_B_move(0, 2, 1, 4)).to eq false
    end
  end
end

describe "#validates_move" do
  context "return true if R is making a valid move" do
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, "BK", nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, "RK", nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    it "will return true for B" do
      expect(game.validates_move("B", "black", [0, 2],[ 1, 3])).to eq true
    end
    it "will return false for B" do
      expect(game.validates_move("B", "black", [0, 2],[1, 4])).to eq false
    end
    it "will return true for R" do
      expect(game.validates_move("R", "red", [4, 2],[ 3, 1])).to eq true
    end
    it "will return false for R" do
      expect(game.validates_move("R", "red", [4, 2],[5, 1])).to eq false
    end
    it "will return true RK" do
      expect(game.validates_move("RK", "red", [6, 1],[ 7, 2])).to eq true
    end
    it "will return true RK" do
      expect(game.validates_move("RK", "red", [6, 1],[5, 2])).to eq true
    end
    it "will return true BK" do
      expect(game.validates_move("BK", "black", [4, 2],[ 5, 3])).to eq true
    end
    it "will return false BK" do
      expect(game.validates_move("BK", "black", [4, 2],[3, 3])).to eq true
    end
  end
end

describe "# can_eat_down?" do
  context "checks the black piece's ability to eat downwards" do
    let (:user) do
      User.new({first_name: "jackie", email: "jackie@mail.com", password: "apples"})
    end
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, "BK" , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, "RK", nil, nil, "R", nil, "R"],
      [nil, "B", nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    let (:gameplay) do
      Gameplayer.new({team: "black", user_id: User.last.id, game_id: Game.last.id})
    end
    it "will return an array to_coordinates" do
      expect(game.can_eat_down?(3, 5, "R")).to eq [5, 3]
      expect(game.can_eat_down?(1, 5, "R")).to eq [3, 3]
      expect(game.can_eat_down?(5, 2, "B")).to eq [7, 0]
    end
  end
end

describe "# can_eat_up?" do
  context "checks the black piece's ability to eat downwards" do
    let (:user) {User.new(first_name: "jackie", email: "jackie@mail.com", password: "apples")}
    let!(:game) {Game.new(name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, "R", nil],
      [nil, nil, nil, nil, nil, "BK" , nil, nil],
      [nil, nil, nil, nil, "R", nil, nil, nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, "RK", nil, nil, "R", nil, "R"],
      [nil, "B", nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      )}
    let!(:gameplay) {Gameplayer.create(team: "black", user_id: user.id, game_id: game.id)}
    it "will return an array to_coordinates if true" do
      expect(game.can_eat_up?(4, 4, "B")).to eq [2, 6]
      expect(game.can_eat_up?(1, 5, "R")).to eq nil
    end
  end
end

describe "#possible_moves" do
  context "checks to see if there are any possible moves on the board " do
    let (:user) do
      User.new({first_name: "jackie", email: "jackie@mail.com", password: "apples"})
    end
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, "RK", nil],
      [nil, nil, nil, nil, nil, "BK" , nil, nil],
      [nil, nil, nil, nil, "R", nil, nil, nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, "RK", nil, nil, "R", nil, "R"],
      [nil, "B", nil, nil, "R", nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    let (:gameplay) do
      Gameplayer.new({team: "black", user_id: User.last.id, game_id: Game.last.id})
    end
    it "will return true if a move is possible for that certain piece" do
      expect(game.possible_moves("B", 0, 1)).to be true
      expect(game.possible_moves("RK", 0, 7)).to be true
      expect(game.possible_moves("B", 6, 1)).to be true
      expect(game.possible_moves("R", 5, 5)).to be false
    end
  end
end

describe "#becoming_king" do
  context "once the opposing piece has reached the end of the oppent's board,
  it becomes a king" do
    let (:user) do
      User.new({first_name: "jackie", email: "jackie@mail.com", password: "apples"})
    end
    let (:game) do
      Game.new({name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, "RK", nil],
      [nil, nil, nil, nil, nil, "BK" , nil, nil],
      [nil, nil, nil, nil, "R", nil, nil, nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, "RK", nil, nil, "R", nil, "R"],
      [nil, "B", nil, nil, "R", nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      })
    end
    let (:gameplay) do
      Gameplayer.new({team: "black", user_id: User.last.id, game_id: Game.last.id})
    end
    it "will return true if a move is possible for that certain piece" do
      expect(game.becoming_king("R", 0, 1)).to eq "RK"
      expect(game.becoming_king("B", 7, 1)).to eq "BK"
      expect(game.becoming_king("B", 5, 1)).to eq nil
    end
  end
end

describe "# team_players" do
  context " returns an array of players" do
    let!(:user) {User.create(first_name: "jackie", email: "jackie@mail.com", password: "apples")}
    let!(:game) {Game.create(name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      )}
    let!(:gameplay) {Gameplayer.create(team: "black", user_id: user.id, game_id: game.id)}
    it "will return an array of teams" do
      expect(game.team_players[0][0].first_name).to eq "jackie"
      expect(game.team_players[1]).to eq []
    end
  end
  context " returns an array of players" do
    let!(:user) {User.create(first_name: "jackie", email: "jackie@mail.com", password: "apples")}
    let!(:user1) {User.create(first_name: "poro", email: "poro@mail.com", password: "apples")}

    let!(:game) {Game.create(name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      )}
    let!(:gameplay) {Gameplayer.create(team: "black", user_id: user.id, game_id: game.id)}
    let!(:gameplay1) {Gameplayer.create(team: "red", user_id: user1.id, game_id: game.id)}
    it "will return an array of teams" do

      expect(game.team_players[0][0].first_name).to eq "jackie"
      expect(game.team_players[1][0].first_name).to eq "poro"
    end
  end
end

describe "#a_piece_jumped" do
  context "expect piece jumped to be nil" do
    let!(:game) {Game.create(name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "B", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]]
      )}
    it "removes the piece that was jumped" do
      game.a_piece_jumped(5, 3, 3, 5)
      expect(game.state_of_piece[(5 + 3)/2][(5 + 3)/2]).to eq nil
    end
  end
end

describe "#update_turn" do
  context "expect piece jumped to be nil" do
    let!(:game) {Game.create(name: "testing", state_of_piece:
      [[nil, "B", nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil , nil, nil],
      [nil, nil, nil, nil, "R", nil, "R", nil],
      [nil, nil, nil, nil, nil, "B", nil, nil],
      [nil, nil, nil, nil, "B", nil, "R", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"],
      [nil, nil, nil, nil, nil, nil, "B", nil],
      [nil, nil, nil, nil, nil, "R", nil, "R"]], turn: 2
      )}
    it "removes the piece that was jumped" do
      game.update_turn([5, 3], [3, 5], "red")
      expect(game.history_of_pieces).to eq [[5, 3, 3, 5]]
      expect(game.turn).to eq 3
    end
  end
  # context "expect piece jumped to be nil" do
  #   let!(:game) {Game.create(name: "testing", state_of_piece:
  #     [[nil, "B", nil, nil, nil, nil, nil, nil],
  #     [nil, nil, nil, nil, nil, nil , nil, nil],
  #     [nil, nil, nil, nil, "B", nil, "R", nil],
  #     [nil, nil, nil, nil, nil, "B", nil, nil],
  #     [nil, nil, nil, nil, "B", nil, "R", nil],
  #     [nil, nil, nil, nil, nil, "R", nil, "R"],
  #     [nil, nil, nil, nil, nil, nil, "B", nil],
  #     [nil, nil, nil, nil, nil, "R", nil, "R"]], turn: 2
  #     )}
  #   it "removes the piece that was jumped" do
  #     game.update_turn([5, 3], [3, 5], "red")
  #     expect(game.history_of_pieces).to eq [[5, 3, 3, 5]]
  #     expect(game.turn).to eq 2
  #   end
  # end
end

describe "#error_message" do
  context "illegal moves occured"do
    let!(:game) {Game.create(name: "hogwarts", state_of_piece:
    [[nil, "B", nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil , nil, "B"],
    [nil, nil, nil, nil, "R", nil, nil, nil],
    [nil, nil, nil, nil, nil, "B", nil, nil],
    [nil, nil, nil, nil, "B", nil, "R", nil],
    [nil, nil, nil, "R", nil, "R", nil, "B"],
    [nil, nil, nil, nil, nil, nil, "B", nil],
    [nil, nil, nil, nil, nil, "R", nil, "R"]],
    turn: 1)}
    it "reutrns an error message" do
      expect(game.error_message("red", "R", [5, 3], [3, 5])).to eq ("It is not your turn!")
      expect(game.error_message("black", nil, [0, 0], [1, 1])).to eq ("That piece does not exist")
      expect(game.error_message("black", "R", [5, 3], [3, 5])).to eq ("This is not your piece")
      expect(game.error_message("black", "B", [1, 7], [2, 8])).to eq ("You are off the board")
      expect(game.error_message("black", "B",  [1, 7], [2, 6])).to eq ("There is another piece you MUST move")

    end
  end
  context "illegal moves occured"do
    let!(:game) {Game.create(name: "hogwarts", state_of_piece:
    [[nil, "B", nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil , nil, "B"],
    [nil, nil, nil, nil, "R", nil, nil, nil],
    [nil, nil, nil, nil, nil, "B", nil, nil],
    [nil, nil, nil, nil, "B", nil, "R", nil],
    [nil, nil, nil, "R", nil, "R", nil, "B"],
    [nil, nil, "B", nil, nil, nil, "B", nil],
    [nil, nil, nil, nil, nil, "R", nil, "R"]],
    turn: 1)}
    it "reutrns an error message" do

      expect(game.error_message("black", "B", [4, 4], [4, 4])).to eq ("That is not a legal move")
    end
  end

end
