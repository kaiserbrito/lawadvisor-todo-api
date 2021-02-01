FactoryBot.define do
  factory :task do
    description { Faker::Lorem.word }
    done { false }
  end
end
