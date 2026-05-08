require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin)   { create(:user, :admin) }
  let!(:user_a) { create(:user, role: "parent") }
  let!(:user_b) { create(:user, role: "student") }

  describe "GET /admin/users" do
    context "as admin" do
      before { sign_in admin }

      it "returns 200 and lists all users" do
        get admin_users_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(user_a.email)
        expect(response.body).to include(user_b.email)
      end
    end

    context "as non-admin" do
      before { sign_in user_a }

      it "redirects away" do
        get admin_users_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not logged in" do
      it "redirects to sign in" do
        get admin_users_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/users/:id/edit" do
    context "as admin" do
      before { sign_in admin }

      it "returns 200" do
        get edit_admin_user_path(user_a)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as non-admin" do
      before { sign_in user_a }

      it "redirects away" do
        get edit_admin_user_path(user_b)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /admin/users/:id" do
    context "as admin" do
      before { sign_in admin }

      it "updates name and role, redirects to index" do
        patch admin_user_path(user_a), params: {
          user: { first_name: "Betty", last_name: "Smith", role: "student" }
        }
        expect(response).to redirect_to(admin_users_path)
        user_a.reload
        expect(user_a.first_name).to eq("Betty")
        expect(user_a.role).to eq("student")
      end

      it "can grant admin privileges" do
        patch admin_user_path(user_a), params: { user: { admin: true } }
        expect(user_a.reload.admin).to be true
      end

      it "renders edit with error on invalid email" do
        patch admin_user_path(user_a), params: { user: { email: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "as non-admin" do
      before { sign_in user_a }

      it "redirects away without updating" do
        patch admin_user_path(user_b), params: { user: { role: "teacher" } }
        expect(response).to redirect_to(root_path)
        expect(user_b.reload.role).not_to eq("teacher")
      end
    end
  end

  describe "DELETE /admin/users/:id" do
    context "as admin" do
      before { sign_in admin }

      it "deletes the user and redirects" do
        expect {
          delete admin_user_path(user_a)
        }.to change(User, :count).by(-1)
        expect(response).to redirect_to(admin_users_path)
      end

      it "does not allow deleting self" do
        expect {
          delete admin_user_path(admin)
        }.not_to change(User, :count)
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "as non-admin" do
      before { sign_in user_a }

      it "redirects away without deleting" do
        expect {
          delete admin_user_path(user_b)
        }.not_to change(User, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
