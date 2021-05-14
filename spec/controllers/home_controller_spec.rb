# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  let!(:user) { create(:user) }
  let!(:appointment) { create(:appointment, user: user, highlight: true) }

  describe '#index' do
    it 'works' do
      # Since we randomize appointments on the homepage, we need to delete all existing appointments
      # to make sure our new appointment shows up in @featured_appointments. Not graceful but it works
      Appointment.delete_all
      new_appointment = FactoryBot.create(:appointment, user: user, highlight: true)
      expect(Appointment.count).to eq(1)

      get :index
      expect(assigns(:featured_appointments)).to include(new_appointment)
      expect(response).to be_successful
    end

    it 'works when signed in' do
      sign_in(user)
      get :index
      expect(response).to be_successful
    end

    it 'doesnt show the same featured appointment twice' do
      appointment2 = create(:appointment_with_type, user: user, highlight: true, appointment_type_list: ['Track the outbreak', 'Scale testing'])
      get :index
      featured_ids = assigns(:appointment_categories).map(&:featured_appointments).flatten.map(&:id)
      expect(featured_ids.count(appointment2.id)).to eq(1)
    end
  end
end
