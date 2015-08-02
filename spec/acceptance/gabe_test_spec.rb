require "spec_helper"

describe "crazytown" do
  it "works" do
    define_model "User", name: :string, email: :string

    FactoryGirl.define do
      factory :user do
        sequence(:name) {|n| "Person #{n}"}
        email { "#{name.downcase.parameterize}@example.com" }

        trait :foo do
          name "Josh"
        end
      end
    end

    user = FactoryGirl.build(:user)

    expect(user.email).to match /@example\.com$/
  end
end
