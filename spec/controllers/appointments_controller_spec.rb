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

    describe 'Requesting' do
      let!(:no_patients_appointment) { create(:appointment, user: user, accepting_patients: false) }

      it 'filters by ?accepting_patients=0' do
        get :index, params: { accepting_patients: '0' }
        expect(response).to be_successful
        expect(assigns(:appointments)).to include(no_patients_appointment)
        expect(assigns(:appointments)).to_not include(appointment)
      end

      it 'filters by ?accepting_patients=1' do
        get :index, params: { accepting_patients: '1' }
        expect(response).to be_successful
        expect(assigns(:appointments)).to_not include(no_patients_appointment)
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
      expect(json['patient_location']).to eq(appointment.patient_location)
      expect(json['accepting_patients']).to eq(appointment.accepting_patients)
      expect(json['to_param']).to eq(appointment.to_param)
    end

    describe 'Requesting' do
      it 'hide patient info' do
        appointment.number_of_patients = '100'
        appointment.accepting_patients = false
        appointment.save
        get :show, params: { id: appointment.to_param }
        expect(response).to be_successful
        expect(response.body).to_not include('Number of patients')
        expect(response.body).to_not include('Sign up to request')
      end

      it 'show patient info' do
        appointment.number_of_patients = '100'
        appointment.accepting_patients = true
        appointment.save
        get :show, params: { id: appointment.to_param }
        expect(response).to be_successful
        expect(response.body).to include('Number of patients')
        expect(response.body).to include('Sign up to request')
      end

      it 'shows patient button if your profile is complete' do
        user = create(:user_complete_profile)
        sign_in user
        user.skill_list.add('Design')
        user.save
        appointment.skill_list.add('Design')
        appointment.save
        get :show, params: { id: appointment.to_param }
        expect(response.body).to include('patients-btn')
      end

      it 'shows patient filled button if you dont have the right skills' do
        user = create(:user_complete_profile)
        sign_in user
        get :show, params: { id: appointment.to_param }
        expect(response.body).to include('patients-filled-btn')
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
    it 'updating accepting_patients works' do
      sign_in user
      expect(appointment.accepting_patients).to eq(true)
      put :update, params: { id: appointment.id, appointment: { accepting_patients: false } }
      expect(response).to be_redirect
      expect(assigns(:appointment).accepting_patients).to eq(false)
    end
  end

  describe 'DELETE #destroy' do
    it 'works' do
      pending 'TODO'
      fail
    end
  end

  describe 'POST #toggle_patient' do
    it 'requests you if you are not currently a patient' do
      pending 'TODO'
      fail
    end

    it 'tracks an event if you are not currently a patient' do
      pending 'TODO'
      fail
    end

    it 'unrequests you if you had already requested' do
      pending 'TODO'
      fail
    end
  end
end
