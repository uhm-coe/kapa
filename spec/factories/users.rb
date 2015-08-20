FactoryGirl.define do
  factory :user, :class => Kapa::User do
    uid Faker::Number.number(8)
    category "local"
    dept [""]
    status 3
    emp_status 3
    password "password"
    association :person

    #before(:create) do |user|
    #  user.apply_role(:admin)
    #end
  end

  factory :person, :class => Kapa::Person do
    last_name Faker::Name.last_name
    first_name Faker::Name.first_name
  end
end

