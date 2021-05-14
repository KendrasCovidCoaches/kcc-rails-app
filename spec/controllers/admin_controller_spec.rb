require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  let!(:user) { create(:user) }
  let!(:admin) { User.where(email: COACHES[0]).first || create(:user, email: COACHES[0]) }

  describe 'POST #delete_user' do
    let!(:valid_params) { { user_id: user.to_param } }

    # TODO refactor to account for shared `ensure_admin` filter
    # Then just test that each method calls `ensure_admin`, like so
    it 'calls ensure_admin' do
      expect(controller).to receive(:ensure_admin)
      post :delete_user, params: valid_params
    end

    it "returns 401 Unauthorized if you're not logged in" do
      post :delete_user, params: valid_params
      expect(response).to redirect_to(appointments_path)
    end

    it "returns 401 unauthorized if you're logged in but not an admin" do
      sign_in(user)
      post :delete_user, params: valid_params
      expect(response).to redirect_to(appointments_path)
    end

    it "works if you're signed-in as an admin" do
      sign_in(admin)
      post :delete_user, params: valid_params
      expect(response).to redirect_to(patients_path)
      expect(flash[:notice]).to match(/User deleted/)
    end

    it "fails if you don't specify a valid user's id" do
      sign_in(admin)
      expect(User.where(id: 666)).to be_blank
      expect {
        post :delete_user, params: { user_id: 666 }
        expect(response.status).to eq(404)
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #toggle_highlight' do
    let!(:appointment) { create(:appointment, user: user) }
    let!(:valid_params) { { appointment_id: appointment.to_param } }

    it 'calls ensure_admin' do
      expect(controller).to receive(:ensure_admin)
      post :toggle_highlight, params: valid_params
    end

    it 'highlights if appointment is not currently highlighted. highlit? highlighted' do
      sign_in(admin)
      expect(appointment.highlight?).to eq(false)
      post :toggle_highlight, params: valid_params
      expect(response).to redirect_to(appointment_path(appointment))
      expect(appointment.reload.highlight?).to eq(true)
      expect(flash[:notice]).to match(/Appointment highlighted/)
    end

    it 'unhighlights if appointment was already highlighted' do
      sign_in(admin)
      active_appointment = create(:appointment, user: user, highlight: true)
      expect(active_appointment.highlight?).to eq(true)
      post :toggle_highlight, params: { appointment_id: active_appointment.to_param }
      expect(response).to redirect_to(appointment_path(active_appointment))
      expect(active_appointment.reload.highlight?).to eq(false)
      expect(flash[:notice]).to match(/Removed highlight/)
    end
  end
end
