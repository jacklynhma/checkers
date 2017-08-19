require "rails_helper"


describe Comment do
  it { should have_valid(:body).when("Test") }
  it { should_not have_valid(:body).when(nil, "") }

  it { should belong_to :user}
  it { should belong_to :game}
end
