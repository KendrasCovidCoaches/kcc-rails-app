class Appointment < ApplicationRecord
    belongs_to :user
    belongs_to :request

    acts_as_taggable_on :communications
end
