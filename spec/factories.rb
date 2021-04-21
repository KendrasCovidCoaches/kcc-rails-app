# frozen_string_literal: true

FactoryBot.define do
  factory :coach do
    user_id { 1 }
    first_name { "MyString" }
    last_name { "MyString" }
  end

  factory :content do
    
  end

  factory :post do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraphs(number: rand(4...20)).join("\n") }
    links { Faker::Internet.url }
  end

  factory :patient_group do
  end

  factory :user do
    name { 'Bob Isok' }
    sequence(:email) { |n|
      # puts "HI"; puts n.inspect; "user#{n}@example.com"
      gen = "user_#{rand(1000)}@factory.com"
      while User.where(email: gen).exists?
        gen = "user_#{rand(1000)}@factory.com"
      end
      gen
    }
    password { 'df823jls18fk350f' }

    factory :user_visible do
      visibility { true }
    end
  end

  factory :user_admin, parent: :user do
    email { 'email@address.com' } # should match .env.test
  end

  factory :user_complete_profile, parent: :user do
    about { 'About' }
    profile_links { 'Profile' }
    location { 'location' }
    skill_list { ['Analytics'] }
  end

  factory :request do
    name { 'My First Appointment' }
    description { 'My description' }
    patient_location { 'location' }
    status { Settings.request_statuses.first }
  end

  factory :request_with_type, parent: :request do
    request_type_list { ['Track the outbreak'] }
  end

  factory :patient do
    # ...
  end

  factory :offer do
    name { 'Free Veggie Burgers' }
    description { "They're delicious and animal-free" }
    limitations { 'Contains gluten' }
    redemption { 'https://veggieboigas.com' }
    location { 'N/A' }
  end
end
