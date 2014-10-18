/*
 * @author	Elijah Freestone 
 *
 * Project	Project1Android
 * 
 * @class 	CPM term 1410
 * 
 * Package	com.elijahfreestone.project1android
 * 
 * Date		Sep 29, 2014
 */

package com.elijahfreestone.project1android;

import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.SignUpCallback;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

// TODO: Auto-generated Javadoc
/**
 * The Class LoginAndSignupActivity handles user login and signup.
 */
public class LoginAndSignupActivity extends Activity {
	String TAG = "LoginAndSignupActivity";
	EditText usernameEditText;
	EditText passwordEditText;
	String usernameEntered;
	String passwordEntered;
	Button loginButton;
	Button signupButton;
	
	/* (non-Javadoc)
	 * @see android.app.Activity#onCreate(android.os.Bundle)
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login); 
		
		//Grab EditTexts and buttons
		usernameEditText = (EditText) findViewById(R.id.usernameEditText);
		passwordEditText = (EditText) findViewById(R.id.passwordEditText);
		loginButton = (Button) findViewById(R.id.loginButton);
		signupButton = (Button) findViewById(R.id.signupButton);
		
		//Login button clicked
		loginButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				onLoginClicked();
				 
			}
		});  //setOnClickListener close
		
		//Signup button clicked
		signupButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				onSignupClicked();
				
			}
		}); //setOnClickListener close
		
	} //onCreate close
	
	/**
	 * On login clicked.
	 */
	private void onLoginClicked(){
		//Retrieve input username and password
		usernameEntered = usernameEditText.getText().toString();
		passwordEntered = passwordEditText.getText().toString();
		
		//Process and verify login info entered
		ParseUser.logInInBackground(usernameEntered, passwordEntered, new LogInCallback() {
			
			@Override
			public void done(ParseUser user, ParseException error) {
				if (user != null) {
					Log.i(TAG, usernameEntered + "logged in");
					Toast.makeText(getApplicationContext(), "Login Successful",
                            Toast.LENGTH_LONG).show();
					Intent loggedIntent = new Intent(LoginAndSignupActivity.this, MainActivity.class);
					startActivity(loggedIntent);
					finish(); 
				} else {
					String failedMessage = " please try again";
					if (usernameEntered.equals("")) {
						failedMessage = " please enter a username";
					}
					if (passwordEntered.equals("")) {
						failedMessage = " please enter a password";
					} 
					
					Toast.makeText(getApplicationContext(), "Login failed, " + failedMessage,
                            Toast.LENGTH_LONG).show();
				}
			}
		}); //logInInBackground close
		
	} //onLoginClicked close
	
	/**
	 * On signup clicked.
	 */
	private void onSignupClicked() {
		// Retrieve input username and password
		usernameEntered = usernameEditText.getText().toString();
		passwordEntered = passwordEditText.getText().toString();

		//Check if username or password are blank
		if (usernameEntered.equals("") || passwordEntered.equals("")) {
			Toast.makeText(getApplicationContext(), "Both fields are required to sign up", 
					Toast.LENGTH_LONG).show();
		} else {
			// Create new user and save to Parse with entered info
			ParseUser newUser = new ParseUser();
			newUser.setUsername(usernameEntered);
			newUser.setPassword(passwordEntered);
			newUser.signUpInBackground(new SignUpCallback() {

				@Override
				public void done(ParseException error) {
					if (error == null) {
						// Show a simple Toast message upon successful
						// registration
						Toast.makeText(getApplicationContext(), "Signup successful, please log in.",
								Toast.LENGTH_LONG).show();
					} else {
						Toast.makeText(getApplicationContext(), "An error occured, please try again.",
								Toast.LENGTH_LONG).show();
					}
				}
			}); // signUpInBackground close
		}

	} // onSignupClicked
	
}
