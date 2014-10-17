/*
 * @author	Elijah Freestone 
 *
 * Project	Project3Android
 * 
 * @class 	CPM term 1410
 * 
 * Package	com.elijahfreestone.project3android
 * 
 * Date		Oct 11, 2014
 */

package com.elijahfreestone.project3android;

import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.SignUpCallback;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
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
	static Context myContext;
	
	/* (non-Javadoc)
	 * @see android.app.Activity#onCreate(android.os.Bundle)
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login); 
		myContext = this;
		
		//Grab EditTexts and buttons
		usernameEditText = (EditText) findViewById(R.id.usernameEditText);
		passwordEditText = (EditText) findViewById(R.id.passwordEditText);
		loginButton = (Button) findViewById(R.id.loginButton);
		signupButton = (Button) findViewById(R.id.signupButton);
		
		//Login button clicked
		loginButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (ConnectionManager.connectionStatus(myContext)) {
					//Connection exists, attempt login 
					onLoginClicked();
				} else {
					//No network, show error alert
					noConnectionAlert();
				}
			}
		});  //setOnClickListener close
		
		//Signup button clicked
		signupButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (ConnectionManager.connectionStatus(myContext)) {
					//Connection exists, attempt sign up
					onSignupClicked();
				} else {
					//No network, show error alert
					noConnectionAlert();
				}
			}
		}); //setOnClickListener close
		
	} //onCreate close
	
	/**
	 * On login clicked verifies the user info on Parse before logging in.
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
					//Login successful, dismiss view
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
					
					//Create alert message and show
					String loginFailed = "Login failed, ";
					String failedAlert = loginFailed + failedMessage;
					errorAlert(failedAlert);
				}
			}
		}); //logInInBackground close
		
	} //onLoginClicked close
	
	/**
	 * On signup clicked sends new login info to Parse.
	 */
	private void onSignupClicked() {
		// Retrieve input username and password
		usernameEntered = usernameEditText.getText().toString();
		passwordEntered = passwordEditText.getText().toString();

		//Check if username or password are blank
		if (usernameEntered.equals("") || passwordEntered.equals("")) {
			String bothFields = "Both fields are required to sign up";
			errorAlert(bothFields);
		} else {
			// Create new user and save to Parse with entered info
			ParseUser newUser = new ParseUser();
			newUser.setUsername(usernameEntered);
			newUser.setPassword(passwordEntered);
			newUser.signUpInBackground(new SignUpCallback() {

				@Override
				public void done(ParseException error) {
					if (error == null) {
						// Show a simple Toast message upon successful registration
						Toast.makeText(getApplicationContext(), "Signup successful!",
								Toast.LENGTH_LONG).show();
						//Autolog the new user
						onLoginClicked();
					} else {
						String signupError = "An error occurred, please try again.";
						errorAlert(signupError);
					}
				}
			}); // signUpInBackground close
		}

	} // onSignupClicked
	
	/*
	 * Custom method to show error alert
	 */
	public static void errorAlert(String alertMessage) {
		// Create alert dialog for no connection
		AlertDialog alertDialog = new AlertDialog.Builder(myContext).create();
		alertDialog.setTitle(R.string.errorTitle);
		// Set alert message. setMessage only has a charSequence
		// version so getString must be used.
		alertDialog.setMessage(alertMessage);
		alertDialog.setButton(DialogInterface.BUTTON_POSITIVE, "OK",
				(DialogInterface.OnClickListener) null);
		alertDialog.show();
	} //errorAlert close
	
	/*
	 * Custom method to show no connection alert
	 */
	public static void noConnectionAlert() {
		// Create alert dialog for no connection
		AlertDialog alertDialog = new AlertDialog.Builder(myContext).create();
		alertDialog.setTitle(R.string.noConnectionTitle);
		// Set alert message. setMessage only has a charSequence
		// version so getString must be used.
		alertDialog.setMessage("A network connection is required to sign in or create an account. "
				+ "Please check your network connection and try again");
		alertDialog.setButton(DialogInterface.BUTTON_POSITIVE, "OK",
				(DialogInterface.OnClickListener) null);
		alertDialog.show();
	} //noConnectionAlert close
	
}
