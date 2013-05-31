require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_title('Sign In') }
    it { should have_content('Sign In') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign In" }

      it { should have_title('Sign In') }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_error_message }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      it { should have_title(user.name) }
      it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign Out',    href: signout_path) }
      it { should_not have_link('Sign In', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign Out" }

        it { should have_link('Sign In') }
        it { should_not have_link('Profile') }
        it { should_not have_link('Settings') }
        it { should_not have_link('Sign Out') }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }

          it { should have_title('Sign In') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }

          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }

          it { should have_title('Sign In') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }

          it { should have_title('Sign In') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }

          it { should have_title('Sign In') }
        end

      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in_valid_signin(user)
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end

          describe "when signing in again" do
            before do
              delete signout_path
              valid_signin(user)
            end

            it "should render the default (profile) page" do
              expect(page).to have_title(user.name) 
            end
          end

          describe "visiting Users#new page" do
            before { visit signup_path }

            it { should_not have_title('Sign Up') }
          end

          describe "submitting POST request to Users#create action" do
            before do
              user_params = { name: "test", email: "testloggedin@example.com", 
                              password: "password", password_confirm: "password" }
              post users_path, user: user_params
            end

            specify { expect(response).to redirect_to(root_path) }
          end

        end
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "in the Relationships controller" do

        describe "submitting to the create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }          
        end

      end

    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
 
      before { valid_signin user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }

        it { should_not have_title(full_title('Edit user')) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }

        specify { expect(response).to redirect_to(root_path) }
      end

      describe "submitting to the destroy action for microposts" do
        before do
          FactoryGirl.create(:micropost, user: wrong_user)
          delete micropost_path(wrong_user.microposts.first)
        end

        specify { expect(response).to redirect_to(root_path) }
      end

    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { valid_signin non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_path) }        
      end
    end

  end

end