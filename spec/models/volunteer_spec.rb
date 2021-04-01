require 'rails_helper'

RSpec.describe Volunteer, type: :model do
  let!(:user) { create(:user) }
  let!(:appointment) { create(:appointment, user: user) }

  it 'factory is valid, given valid associations' do
    # Note that user is volunteering for their own appointment, but this is allowed
    volunteer = build(:volunteer, user: user, appointment: appointment)
    expect(volunteer.valid?).to eq(true)
  end

  it 'is invalid without a user' do
    volunteer = build(:volunteer, user: nil, appointment: appointment)
    expect(volunteer.valid?).to eq(false)
  end

  it 'is invalid without a appointment' do
    volunteer = build(:volunteer, user: user, appointment: nil)
    expect(volunteer.valid?).to eq(false)
  end
end
