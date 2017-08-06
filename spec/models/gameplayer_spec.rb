require 'rails_helper'

describe Gameplayer do
  it { should have_valid(:team).when("Test") }
  it { should_not have_valid(:team).when(nil, "")}

  it { should belong_to :user}
  it { should belong_to :game}
end
