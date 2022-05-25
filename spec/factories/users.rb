FactoryBot.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  factory :user do
    email
    first_name { 'Kianu' }
    last_name { 'Rives' }
    password { 'valid-password' }
  end
end
