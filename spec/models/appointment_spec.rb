require 'rails_helper'

RSpec.describe Appointment, type: :model do
  let(:user) { build(:user) }
  let(:appointment) { build(:appointment, user: user) }

  it 'factory is valid' do
    user = create(:user)
    appointment = build(:appointment, user: user)
    expect(appointment).to be_valid
  end

  it 'is invalid without a name' do
    appointment = build(:appointment, name: nil)
    expect(appointment).to_not be_valid
  end

  it 'is invalid without a user' do
    appointment = build(:appointment, user: nil)
    expect(appointment).to_not be_valid
  end

  it 'accepting_volunteers defaults true' do
    appointment = build(:appointment, user: nil)
    expect(appointment.accepting_volunteers).to eq(true)
  end

  describe 'can_edit?' do
    it 'random user cant edit' do
      expect(appointment.can_edit?(build(:user))).to eq(false)
    end

    it 'appointment_owner can edit' do
      appointment_owner = appointment.user
      expect(appointment.can_edit?(appointment_owner)).to eq(true)
    end

    it 'admin can edit' do
      admin_user = build(:user_admin)
      expect(appointment.can_edit?(admin_user)).to eq(true)
    end
  end

  describe 'Category & Cover photo' do
    Settings.appointment_categories.each do |category|
      category['appointment_types'].to_a.each do |type|
        it "#{type} returns #{category.name}" do
          appointment.appointment_type_list.add(type)
          expect(appointment.category).to eq(category.name)
        end
      end
    end

    it 'appointment defaults to medical with no type' do
      expect(appointment.category).to eq('Community')
    end

    describe '#cover_photo' do
      let(:subject) { appointment.cover_photo(name)}
      let(:helpers) { double() }

      before do 
        allow(ActionController::Base).to receive(:helpers).and_return(helpers)
        allow(helpers).to receive(:asset_pack_path)
      end

      context 'when no filename is provided' do
        let(:name) { nil }

        it 'calls asset_pack_path with the correct parameter' do
          appointment.appointment_type_list.add('Reduce spread')

          expect(helpers).to receive(:asset_pack_path).with('media/images/prevention-default.png')

          subject
        end
      end

      context 'when a filename is provided' do
        let(:name) { 'Test' }

        it 'calls asset_pack_path with the correct parameter' do
          expect(helpers).to receive(:asset_pack_path).with('media/images/test-default.png')

          subject
        end
      end
    end
  end

  it 'it sets default status' do
    appointment = build(:appointment, status: nil)
    appointment.save
    expect(appointment.status).to eq(Settings.appointment_statuses.first)
  end

  it 'is invalid without a status' do
    appointment = build(:appointment, status: nil)
    expect(appointment).to_not be_valid
  end

  it 'is invalid with wrong status' do
    appointment = build(:appointment, status: 'lol')
    expect(appointment).to_not be_valid
  end
end
