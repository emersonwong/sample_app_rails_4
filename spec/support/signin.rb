module Signin

  def valid_signin(user)
    visit signin_path
    fill_in_valid_signin(user)
  end

  def fill_in_valid_signin(user)
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    # Sign in when not using Capybara as well.
    cookies[:remember_token] = user.remember_token
    click_button "Sign In"
  end

end