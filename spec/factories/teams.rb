FactoryGirl.define do
  factory :team do
    name { Faker::Name.name }
    region { build :region }

  end
end
