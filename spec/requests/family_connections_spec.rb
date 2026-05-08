require 'rails_helper'

RSpec.describe "FamilyConnections", type: :request do
  let(:parent)  { create(:user, role: "parent") }
  let(:student) { create(:user, role: "student") }

  describe "POST /family_connections" do
    context "as a parent adding a student" do
      before { sign_in parent }

      it "creates a pending connection" do
        expect {
          post family_connections_path, params: { email: student.email }
        }.to change(FamilyConnection, :count).by(1)
        expect(FamilyConnection.last.confirmed).to be false
        expect(response).to redirect_to(profile_path)
      end

      it "confirms connection when student already linked the parent" do
        create(:family_connection, parent: parent, student: student, confirmed: false)
        # Student side already created it — parent completing the link confirms it
        post family_connections_path, params: { email: student.email }
        expect(FamilyConnection.find_by(parent: parent, student: student).confirmed).to be true
        expect(response).to redirect_to(profile_path)
      end

      it "handles already-connected gracefully" do
        create(:family_connection, :confirmed, parent: parent, student: student)
        post family_connections_path, params: { email: student.email }
        expect(response).to redirect_to(profile_path)
      end

      it "rejects an unknown email" do
        expect {
          post family_connections_path, params: { email: "nobody@example.com" }
        }.not_to change(FamilyConnection, :count)
        expect(response).to redirect_to(profile_path)
      end

      it "rejects linking to a non-student" do
        post family_connections_path, params: { email: create(:user, :teacher).email }
        expect(response).to redirect_to(profile_path)
      end
    end

    context "as a student adding a parent" do
      before { sign_in student }

      it "creates a pending connection" do
        expect {
          post family_connections_path, params: { email: parent.email }
        }.to change(FamilyConnection, :count).by(1)
        expect(FamilyConnection.last.confirmed).to be false
      end

      it "confirms connection when parent already linked the student" do
        create(:family_connection, parent: parent, student: student, confirmed: false)
        post family_connections_path, params: { email: parent.email }
        expect(FamilyConnection.find_by(parent: parent, student: student).confirmed).to be true
      end
    end

    context "as a teacher" do
      before { sign_in create(:user, :teacher) }

      it "is not allowed" do
        post family_connections_path, params: { email: student.email }
        expect(response).to redirect_to(profile_path)
      end
    end
  end

  describe "DELETE /family_connections/:id" do
    let!(:connection) { create(:family_connection, parent: parent, student: student) }

    context "as the parent in the connection" do
      before { sign_in parent }

      it "destroys the connection" do
        expect {
          delete family_connection_path(connection)
        }.to change(FamilyConnection, :count).by(-1)
        expect(response).to redirect_to(profile_path)
      end
    end

    context "as the student in the connection" do
      before { sign_in student }

      it "destroys the connection" do
        expect {
          delete family_connection_path(connection)
        }.to change(FamilyConnection, :count).by(-1)
      end
    end

    context "as an unrelated user" do
      before { sign_in create(:user) }

      it "is rejected" do
        expect {
          delete family_connection_path(connection)
        }.not_to change(FamilyConnection, :count)
        expect(response).to redirect_to(profile_path)
      end
    end
  end
end
