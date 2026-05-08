require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, email: "test@example.com", password: "password123") }

  describe "GET /users/sign_in" do
    it "returns 200" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users/sign_in" do
    it "signs in with valid credentials and redirects" do
      post user_session_path, params: { user: { email: "test@example.com", password: "password123" } }
      expect(response).to redirect_to(root_path)
    end

    it "rejects invalid credentials" do
      post user_session_path, params: { user: { email: "test@example.com", password: "wrong" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /users/sign_out" do
    before { sign_in user }

    it "signs out and redirects" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end
