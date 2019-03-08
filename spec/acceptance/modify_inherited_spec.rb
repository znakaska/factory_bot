describe "modifying inherited factories with traits" do
  before do
    define_model("Post", name: :string, published: :boolean)
    FactoryBot.define do
      factory :post do
        name { "Post" }
        trait(:published) { published { true } }
        trait(:draft) { published { false } }

        published

        factory :ruby_post do
          name { "Post About Ruby" }
        end

        factory :ruby_draft do
          name { "Draft About Ruby" }
          draft
        end
      end
    end
  end

  it "returns the correct value for overridden attributes from traits" do
    expect(FactoryBot.build(:ruby_post).name).to eq "Post About Ruby"
  end

  it "returns the correct value for overridden attributes from traits defining multiple attributes" do
    expect(FactoryBot.build(:ruby_draft).name).to eq "Draft About Ruby"
    expect(FactoryBot.build(:ruby_draft).published).to eq false
  end

  it "allows modification of attributes created via traits" do
    FactoryBot.modify do
      factory :ruby_draft do
        name { "Modified Draft About Ruby" }
      end
    end

    expect(FactoryBot.build(:ruby_draft).name).to eq "Modified Draft About Ruby"
    expect(FactoryBot.build(:ruby_draft).published).to eq false
  end
end
