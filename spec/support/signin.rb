module Signin

  def valid_signin(user)
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign In"
  end

end