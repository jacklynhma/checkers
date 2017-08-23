require "rails_helper"
require 'byebug'
require 'devise'

RSpec.describe UsersController, type: :controller do
let!(:first_user) { User.create(first_name: "jackie", email: "jackie@gmail.com", password: "apples")}

  describe "GET#Show"do
    it "should go to the user show page" do
      sign_in first_user
      get :show, params: {id: first_user.id}

      expect(response).to render_template(:show)
      expect(response.content_type).to eq "text/html"
    end
  end
end
