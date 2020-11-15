describe "trait inheritance" do
  include FactoryBot::Syntax::Methods

  before do
    FactoryBot.define do
      factory :parent_model, class: Hash do
        parent { true }
        callbacks { [] }

        trait :trait_a do
          parent_trait_a { true }

          after(:build) do |x|
            x[:callbacks] << 'parent.trait_a'
          end
        end

        trait :trait_b do
          parent_trait_b { true }

          after(:build) do |x|
            x[:callbacks] << 'parent.trait_b'
          end
        end

        trait :trait_c do
          trait_a
          trait_b

          parent_trait_c { true }

          after(:build) do |x|
            x[:callbacks] << 'parent.trait_c'
          end
        end

        initialize_with do
          attributes.dup
        end
      end

      factory :child_model_a, parent: :parent_model do
        child_a { true }

        trait :trait_b do
          child_a_trait_b { true }

          after(:build) do |x|
            x[:callbacks] << 'child_a.trait_b'
          end
        end

        trait :trait_c do
          child_a_trait_c { true }

          after(:build) do |x|
            x[:callbacks] << 'child_a.trait_c'
          end
        end
      end

      factory :child_model_b, parent: :parent_model do
        child_b { true }

        trait :trait_a do
          child_b_trait_a { true }

          after(:build) do |x|
            x[:callbacks] << 'child_b.trait_a'
          end
        end

        trait :trait_c do
          child_b_trait_c { true }

          after(:build) do |x|
            x[:callbacks] << 'child_b.trait_c'
          end
        end
      end
    end
  end

  context "factory with a parent" do
    let!(:child_a) { FactoryBot.build(:child_model_a, :trait_c) }
    let!(:child_b) { FactoryBot.build(:child_model_b, :trait_c) }

    let(:parent_attributes) {{
      parent: true,
      parent_trait_a: true,
      parent_trait_b: true,
      parent_trait_c: true,
    }}

    let(:child_a_attributes) { parent_attributes.merge(
      child_a: true,
      child_a_trait_b: true,
      child_a_trait_c: true,
      callbacks: %w[
        parent.trait_a
        parent.trait_b
        child_a.trait_b
        parent.trait_c
        child_a.trait_c
      ]
    )}

    let(:child_b_attributes) { parent_attributes.merge(
      child_b: true,
      child_b_trait_a: true,
      child_b_trait_c: true,
      callbacks: %w[
        parent.trait_a
        child_b.trait_a
        parent.trait_b
        parent.trait_c
        child_b.trait_c
      ]
    )}

    it "assigns attributes in the order they're defined" do
      aggregate_failures do
        expect(child_a).to include(child_a_attributes)
        expect(child_b).to include(child_b_attributes)
      end
    end
  end
end
