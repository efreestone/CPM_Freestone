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

import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.Toast;

import com.parse.FindCallback;
import com.parse.Parse;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
//import com.parse.ParseAnalytics;

public class MainActivity extends Activity {
	String TAG = "MainActivity";
	Button logOutButton; 

    @Override         
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); 
        
        //Initialize Parse with credentials
        Parse.initialize(this, "SAUIZr14D78N6VQVjYfu6KJmNzALl1YE4BCvcq8S", "TCdRBe56XyyV2ra4BBOzfafYsy8dWImtCGlZTWu4");
        //Set default Access Control List to read/write of current user when creating object
        ParseACL.setDefaultACL(new ParseACL(), true);
//        ParseACL defaultACL = new ParseACL();
//        ParseACL.setDefaultACL(defaultACL, true);
        
//        //Test Parse 
//        ParseObject testObject = new ParseObject("TestObject");
//        testObject.put("foo", "bar");
//        testObject.saveInBackground(); 
        
		//Check Parse for current user and auto login if one exists.
		ParseUser currentUser = ParseUser.getCurrentUser();
		if (currentUser != null) { 
			// Send logged in users to Welcome.class
			//Intent autoLogedIntent = new Intent(MainActivity.this, Welcome.class);
			//startActivity(autoLogedIntent);
			Toast.makeText(getApplicationContext(), "Welcome, " + currentUser.getUsername(),
                    Toast.LENGTH_LONG).show();
			Log.i(TAG, "User auto-logged in");
			//finish(); 
		} else {
			// Send user to LoginSignupActivity.class
			Intent loginIntent = new Intent(MainActivity.this, LoginAndSignupActivity.class);
			startActivity(loginIntent);
			finish();  
		} //currentUser if/else close
		
		
		
    } //onCreate close 
    
	void queryParseForItems() {
		// Query Parse for items and parse into arraylist
		ParseQuery<ParseObject> query = ParseQuery.getQuery("newItem");
		query.findInBackground(new FindCallback<ParseObject>() {
			public void done(List<ParseObject> newItemList, ParseException e) {
				if (e == null) {
					Log.i(TAG, "Retrieved " + newItemList.size() + " items");
					for (ParseObject eachItem : newItemList) {
						String itemName = eachItem.getString("Name");
						int itemNumber = eachItem.getInt("Number");
						String itemID = eachItem.getObjectId().toString();

						Log.i(TAG, "Name: " + itemName + ", Number: "
								+ itemNumber + " ID: " + itemID); 
					}
				} else {
					Log.e(TAG, "Error: " + e.getMessage().toString());
				}
			}
		});
	} //queryParseForItems close

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        //Plus button clicked
        if (id == R.id.newPlusButton) {
        	Log.i(TAG, "Plus clicked");
        	Intent newItemIntent = new Intent(MainActivity.this, NewItemActivity.class);
        	startActivity(newItemIntent);
        } 
        //Log out button
        if (id == R.id.logoutButton) {
        	//Log user out
			ParseUser.logOut();
			Log.i(TAG, "User logged out");
			//Present user with login screen
			Intent logoutIntent = new Intent(MainActivity.this, LoginAndSignupActivity.class);
			startActivity(logoutIntent);
			Toast.makeText(getApplicationContext(), "You have been successfully logged out.",
                    Toast.LENGTH_LONG).show();
			//Remove Main activity from stack
			finish();
		}
        return super.onOptionsItemSelected(item);
    } //onOptionsItemSelected close
}
