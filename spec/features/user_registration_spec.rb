### Test for creating an account

require 'spec_helper'

describe "Spec for Sign Up" do     
     it "should create new user account" do     
	visit "/users/sign_up"  
	email = "abcd@example.com" 
	fill_in 'user_name', :with => 'abcdtesttest'   
	fill_in 'user_email', :with => email    
	fill_in 'user_password', :with => "password"    
	fill_in 'user_phone', :with => '0988034925'    
	click_button 'Sign up'    
	expect(page).to have_content "Please follow the link to activate your account"    
    end    
end