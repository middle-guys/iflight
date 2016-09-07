require 'rails_helper'

RSpec.describe FlightsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index, locale: 'en'
      expect(response).to have_http_status(:success)
    end
  end

end
