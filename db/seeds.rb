# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create!(
  email: 'user@gmail.com',
  name: 'Bob Smith',
  password: 'password',
  password_confirmation: 'password',
  about: 'about section',
  location: 'location section',
  profile_links: 'github.com',
  visibility: false
)

# user2 = User.create!(
#   email: 'user2@gmail.com',
#   name: 'Jill Bob',
#   password: 'password',
#   password_confirmation: 'password',
#   about: 'about section',
#   location: 'location section',
#   profile_links: 'github.com',
#   visibility: true,
#   level_of_availability: '99-100 hours a day'
# )

# user3 = User.create!(email: 'user3@gmail.com', name: 'Luv2Code', password: 'password', password_confirmation: 'password')
# user4 = User.create!(email: 'user4@gmail.com', name: 'rspineanu', password: 'password', password_confirmation: 'password')
# user5 = User.create!(email: 'user5@gmail.com', name: 'cpu', password: 'password', password_confirmation: 'password')
# user6 = User.create!(email: 'user6@gmail.com', name: 'jamiew', password: 'password', password_confirmation: 'password')

# PROJECTS
# appointment1 = user.appointments.create(
#   status: Settings.appointment_statuses.shuffle.first,
#   name: 'Act Now Foundation - Import & distribution of 10-minute at home COVID-19 test kits',
#   target_location: 'USA',
#   volunteer_location: 'Anywhere',
#   description: 'A cool description',
#   accepting_volunteers: true,
#   highlight: false)
# appointment1.skill_list.add('Anything')
# appointment1.volunteered_users << user3
# appointment1.save! # FIXME is this necessary? We were modifying associations

# appointment2 = Appointment.create!(
#   user: user2,
#   status: Settings.appointment_statuses.shuffle.first,
#   name: 'One Gazillion Masks',
#   description: 'A cool description',
#   highlight: true,
#   accepting_volunteers: false)
# appointment2.skill_list.add('Design')
#appointment2.save! # FIXME is this necessary?

# appointment3 = Appointment.create(user: user, status: Settings.appointment_statuses.shuffle.first, name: 'Virtual homework supervision to help overwhelmed parents while school is closed appointment', target_location: 'Brooklyn', description: 'With elementary schools suddenly closed for the rest of the year, parents are struggling to balance work, caring for others and the sudden responsibility for keeping their children educated and on track for school.', accepting_volunteers: true, highlight: true)

# appointment4 = Appointment.create(user: user, status: Settings.appointment_statuses.shuffle.first, name: 'Resistbot', description: %{Resistbot is a multipurpose and multifunction chatbot. Right now it's the easiest way to lobby both federal and state officials who are currently crafting a legislative response to the pandemic. Our end goal is to give everyone a voice and able to fight for what they want to see, no matter what it is, from social distancing measures at the state level, to federal UBI stimulus, to no corporate bailouts, to more health care supplies, and more. We've also just built covid-19 specific functionality to inform users of a variety of important information for their home state.}, accepting_volunteers: true, highlight: true)

# appointment5 = Appointment.create(user: user, status: Settings.appointment_statuses.shuffle.first, name: 'Selfie lenses to spread public health into in a fun way appointment ', description: %{We are a group called Lefty Lenses who have been applying selfie lenses (like the Snapchat puppy filter) to politics for the 2020 election. Our lenses have reached 125M people in 10 weeks, and we've spent $0.}, accepting_volunteers: true, highlight: true)

# VOLUNTEERS
# appointment1.volunteered_users << [user3]
# appointment2.volunteered_users << []
# appointment3.volunteered_users << [user, user2, user3, user4]
# appointment4.volunteered_users << [user4, user5]
# appointment5.volunteered_users << [user5, user6]

# SKILLS
# appointment1.skill_list.add('Design')
# appointment1.save


# PROJECT CATEGORIES/PROBLEMS
# appointment1.appointment_type_list.add('Track the outbreak')
# appointment5.appointment_type_list.add('Track the outbreak')
# appointment2.appointment_type_list.add('Reduce spread')

# appointment1.appointment_type_list.add('Scale testing')
# appointment3.appointment_type_list.add('Treatment R&D')
# appointment4.appointment_type_list.add('Medical equipments')

# appointment3.appointment_type_list.add('E-Learning')
# appointment4.appointment_type_list.add('Social giving')
# appointment1.appointment_type_list.add('Map volunteers to needs')
# appointment5.appointment_type_list.add('News and information')

# appointment1.save
# appointment2.save
# appointment3.save
# appointment4.save
# appointment5.save
