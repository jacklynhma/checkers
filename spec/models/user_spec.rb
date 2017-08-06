require 'rails_helper'

describe User do
  it { should have_valid(:first_name).when("Test") }
  it { should_not have_valid(:first_name).when(nil, "")}

  it { should have_many :gameplayers}
  it { should have_many :games}
end
