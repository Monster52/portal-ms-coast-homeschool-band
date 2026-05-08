require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /users/sign_up" do
    it "returns 200" do
      get new_user_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          first_name: "Jane",
          last_name: "Doe",
          email: "jane@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "parent"
        }
      }
    end

    it "creates a user and redirects" do
      expect {
        post user_registration_path, params: valid_params
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(root_path)
    end

    it "does not allow self-assigning admin" do
      post user_registration_path, params: valid_params.deep_merge(user: { admin: true })
      expect(User.last.admin).to be false
    end

    it "renders new with missing required fields" do
      post user_registration_path, params: { user: { email: "", password: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
