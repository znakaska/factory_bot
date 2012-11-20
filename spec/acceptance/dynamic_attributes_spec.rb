require 'spec_helper'

describe 'Dynamic attributes' do
  before do
    define_model('User', name: :string) do
      has_many :posts
    end

    define_model('Post', user_id: :integer) do
      belongs_to :user
    end

    FactoryGirl.define do
      factory :post do
        user
      end

      factory :user do
        posts {|user, e| [e.association(:post, user: user), e.association(:post, user: user)] }
      end
    end
  end

  it 'creates the correct records when calling create' do
    user = FactoryGirl.create(:user)
    user.reload
    user.posts.length.should == 2
    Post.count.should == 2
  end

  it 'creates the correct records when calling build' do
    user = FactoryGirl.build(:user)
    user.posts.length.should == 2
    Post.count.should == 2
  end

  it 'builds stubbed records when calling build_stubbed' do
    user = FactoryGirl.build_stubbed(:user)
    user.posts.length.should == 2
    Post.count.should == 0
  end
end

