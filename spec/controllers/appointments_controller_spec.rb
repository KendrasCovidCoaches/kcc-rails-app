require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do
  render_views

  let!(:user) { create(:user) }
  let!(:appointment) { create(:appointment, user: user) }
  let(:valid_params) { { appointment: { name: 'My Appointment Name', status: Settings.appointment_statuses.first } } }

  describe 'GET #index' do
    it 'works' do
      get :index
      expect(response).to be_successful
      expect(assigns(:appointments)).to include(appointment)
    end

    it 'returns json' do
      get :index, format: 'json'
      json = JSON.parse(response.body)
      expect(response).to be_successful
      expect(json[0]['name']).to be_present
      expect(json[0]['description']).to be_present
      expect(json[0]['to_param']).to be_present
    end

    describe 'Volunteering' do
      let!(:no_volunteers_appointment) { create(:appointment, user: user, accepting_volunteers: false) }

      it 'filters by ?accepting_volunteers=0' do
        get :index, params: { accepting_volunteers: '0' }
        expect(response).to be_successful
        expect(assigns(:appointments)).to include(no_volunteers_appointment)
        expect(assigns(:appointments)).to_not include(appointment)
      end

      it 'filters by ?accepting_volunteers=1' do
        get :index, params: { accepting_volunteers: '1' }
        expect(response).to be_successful
        expect(assigns(:appointments)).to_not include(no_volunteers_appointment)
        expect(assigns(:appointments)).to include(appointment)
      end

      it 'shows appointments filtered by status' do
        appointment.update_attribute(:status, Settings.appointment_statuses.last)
        appointment2 = create(:appointment, user: user, status: Settings.appointment_statuses.first)
        get :index, params: { status: Settings.appointment_statuses.last }
        expect(assigns(:appointments)).to include(appointment)
        expect(assigns(:appointments)).to_not include(appointment2)
      end
    end

    it 'shows highlighted appointments only' do
      appointment.update_attribute(:highlight, true)
      reg_appointment = create(:appointment, user: user, highlight: false)
      get :index, params: { highlight: true }
      expect(response).to be_successful
      expect(assigns(:appointments)).to include(appointment)
      expect(assigns(:appointments)).to_not include(reg_appointment)
    end
  end

  describe 'GET #show' do
    it 'works' do
      # get :show, appointment.id
      get :show, params: { id: appointment.to_param }
      expect(response).to be_successful
      expect(assigns(:appointment)).to eq(appointment)
    end

    it 'returns json' do
      get :show, params: { id: appointment.to_param }, format: 'json'
      json = JSON.parse(response.body)
      expect(response).to be_successful
      expect(json['name']).to eq(appointment.name)
      expect(json['description']).to eq(appointment.description)
      expect(json['volunteer_location']).to eq(appointment.volunteer_location)
      expect(json['accepting_volunteers']).to eq(appointment.accepting_volunteers)
      expect(json['to_param']).to eq(appointment.to_param)
    end

    describe 'Volunteering' do
      it 'hide volunteer info' do
        appointment.number_of_volunteers = '100'
        appointment.accepting_volunteers = false
        appointment.save
        get :show, params: { id: appointment.to_param }
        expect(response).to be_successful
        expect(response.body).to_not include('Number of volunteers')
        expect(response.body).to_not include('Sign up to volunteer')
      end

      it 'show volunteer info' do
        appointment.number_of_volunteers = '100'
        appointment.accepting_volunteers = true
        appointment.save
        get :show, params: { id: appointment.to_param }
        expect(response).to be_successful
        expect(response.body).to include('Number of volunteers')
        expect(response.body).to include('Sign up to volunteer')
      end

      it 'shows volunteer button if your profile is complete' do
        user = create(:user_complete_profile)
        sign_in user
        user.skill_list.add('Design')
        user.save
        appointment.skill_list.add('Design')
        appointment.save
        get :show, params: { id: appointment.to_param }
        expect(response.body).to include('volunteers-btn')
      end

      it 'shows volunteer filled button if you dont have the right skills' do
        user = create(:user_complete_profile)
        sign_in user
        get :show, params: { id: appointment.to_param }
        expect(response.body).to include('volunteers-filled-btn')
      end
    end
  end

  describe 'GET #new' do
    it 'works' do
      sign_in user
      get :new
      expect(response).to be_successful
    end

    it 'redirects you if signed out' do
      get :new
      expect(response).to_not be_successful
    end

    it 'tracks an event' do
      sign_in user
      expect(controller).to receive(:track_event).with('Appointment creation started').and_call_original
      get :new
      # This doesn't work since the GET request sets and deletes the variable within same request
      # expect(session[:track_event]).to eq('Appointment creation started')
      expect(response.body).to match(/Appointment creation started/)
    end
  end

  describe 'GET #edit' do
    it 'works' do
      sign_in user
      get :edit, params: { id: appointment.id }
      expect(response).to be_successful
    end

    it 'fails if not signed in' do
      get :edit, params: { id: appointment.id }
      expect(response).to_not be_successful
    end
  end

  describe 'POST #create' do
    it 'works' do
      sign_in user
      post :create, params: valid_params
      expect(assigns(:appointment)).to be_present
      expect(response).to be_redirect
    end

    it 'tracks an event' do
      sign_in(user)
      post :create, params: valid_params
      expect(session[:track_event]).to eq('Appointment creation complete')
    end
  end

  describe 'PUT #update' do
    it 'updating accepting_volunteers works' do
      sign_in user
      expect(appointment.accepting_volunteers).to eq(true)
      put :update, params: { id: appointment.id, appointment: { accepting_volunteers: false } }
      expect(response).to be_redirect
      expect(assigns(:appointment).accepting_volunteers).to eq(false)
    end
  end

  describe 'DELETE #destroy' do
    it 'works' do
      pending 'TODO'
      fail
    end
  end

  describe 'POST #toggle_volunteer' do
    it 'volunteers you if you are not currently a volunteer' do
      pending 'TODO'
      fail
    end

    it 'tracks an event if you are not currently a volunteer' do
      pending 'TODO'
      fail
    end

    it 'unrequests you if you had already requested' do
      pending 'TODO'
      fail
    end
  end
end
