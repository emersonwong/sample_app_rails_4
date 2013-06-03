require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { valid_signin user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') } 
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }

      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end

    end
  end

  describe "micropost destruction" do

    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end

    describe "as incorrect user" do

      let(:another_user) { FactoryGirl.create(:user, email: "anotheruser@example.com") }

      before do
        valid_signin another_user
        visit user_path user
      end

      it { should_not have_link('delete', href: micropost_path(user.microposts.first)) }
    end

  end

  describe "micropost pagination" do

    before(:all) do
      @user_with_many_posts = FactoryGirl.create(:user, email: "manyposts@example.com")
      @user_with_many_posts.save
      31.times { FactoryGirl.create(:micropost, user: @user_with_many_posts) }
    end

    # this has to be :each because session resets between tests
    before(:each) do
      valid_signin @user_with_many_posts
      visit root_path
    end

    after(:all) do
      @user_with_many_posts.destroy
    end
 
    it { should have_selector('div.pagination') }

    it "should list each micropost" do
      @user_with_many_posts.microposts.paginate(page: 1).each do |mp|
        expect(page).to have_selector('li', text: mp.content)
      end
    end
  end

end
