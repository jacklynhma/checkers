require "rails_helper"

describe Game do
  it { should have_valid(:name).when("Test") }
  it { should_not have_valid(:name).when(nil, "") }

  it { should have_many :gameplayers}
  it { should have_many :users}
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
