require 'rails_helper'

RSpec.describe Patient, type: :model do
  let!(:user) { create(:user) }
  let!(:appointment) { create(:appointment, user: user) }

  it 'factory is valid, given valid associations' do
    # Note that user is patienting for their own appointment, but this is allowed
    patient = build(:patient, user: user, appointment: appointment)
    expect(patient.valid?).to eq(true)
  end

  it 'is invalid without a user' do
    patient = build(:patient, user: nil, appointment: appointment)
    expect(patient.valid?).to eq(false)
  end

  it 'is invalid without a appointment' do
    patient = build(:patient, user: user, appointment: nil)
    expect(patient.valid?).to eq(false)
  end
end
