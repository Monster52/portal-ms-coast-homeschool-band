require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user, first_name: "Jane", last_name: "Doe") }

  describe "GET /profile" do
    context "when logged in" do
      before { sign_in user }

      it "returns 200" do
        get profile_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in" do
      it "redirects to sign in" do
        get profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /profile/edit" do
    before { sign_in user }

    it "returns 200" do
      get edit_profile_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /profile" do
    before { sign_in user }

    it "updates first and last name" do
      patch profile_path, params: { user: { first_name: "Alice", last_name: "Smith" } }
      expect(response).to redirect_to(profile_path)
      expect(user.reload.first_name).to eq("Alice")
      expect(user.reload.last_name).to eq("Smith")
    end

    it "attaches an avatar" do
      file = fixture_file_upload(Rails.root.join("spec/fixtures/files/avatar.png"), "image/png")
      patch profile_path, params: { user: { avatar: file } }
      expect(response).to redirect_to(profile_path)
      expect(user.reload.avatar).to be_attached
    end
  end
end
