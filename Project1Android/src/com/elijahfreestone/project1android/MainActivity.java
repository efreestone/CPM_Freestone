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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.SimpleAdapter;
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
	ListView itemListView;
	ArrayList<HashMap<String, String>> parseArrayList;

    @Override         
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); 
        
        itemListView = (ListView) findViewById(R.id.itemListView);
        
        parseArrayList = new ArrayList<HashMap<String, String>>();
        
        //Initialize Parse with credentials
        Parse.initialize(this, "SAUIZr14D78N6VQVjYfu6KJmNzALl1YE4BCvcq8S", "TCdRBe56XyyV2ra4BBOzfafYsy8dWImtCGlZTWu4");
        //Set default Access Control List to read/write of current user when creating object
        ParseACL.setDefaultACL(new ParseACL(), true);
        
		//Check Parse for current user and auto login if one exists.
		ParseUser currentUser = ParseUser.getCurrentUser();
		if (currentUser != null) { 
			Toast.makeText(getApplicationContext(), "Welcome, " + currentUser.getUsername(),
                    Toast.LENGTH_LONG).show();
			Log.i(TAG, "User auto-logged in");
		} else {
			// Send user to LoginSignupActivity.class
			Intent loginIntent = new Intent(MainActivity.this, LoginAndSignupActivity.class);
			startActivity(loginIntent);
			finish();  
		} //currentUser if/else close
		
		queryParseForItems();
		
    } //onCreate close 
    
	void queryParseForItems() {
		//final ArrayList<Map<String, String>> parseArrayList = new ArrayList<Map<String, String>>();
		// Query Parse for items and parse into arraylist
		ParseQuery<ParseObject> query = ParseQuery.getQuery("newItem");
		query.findInBackground(new FindCallback<ParseObject>() {
			public void done(List<ParseObject> newItemList, ParseException e) {
				if (e == null) {
					Log.i(TAG, "Retrieved " + newItemList.size() + " items");
					//Log.i(TAG, newItemList.toString());
					
					for (ParseObject eachItem : newItemList) { 
						
						String itemName = eachItem.getString("Name"); 
						int itemNumber = eachItem.getInt("Number");
						String itemNumberString = "" + itemNumber;
						String itemID = eachItem.getObjectId().toString();
						HashMap<String, String> objectMap = new HashMap<String, String>();
						objectMap.put("itemName", itemName);
						objectMap.put("itemNumber", itemNumberString);
						objectMap.put("itemID", itemID); 
					
						parseArrayList.add(objectMap);   
						//Log.i(TAG, "Name: " + itemName + ", Number: " + itemNumber + " ID: " + itemID);
					} 
					//Log.i(TAG, parseArrayList.toString());
					SimpleAdapter listAdapter = new SimpleAdapter(
							MainActivity.this, parseArrayList,
							R.layout.listview_row, new String[] { "itemName",
									"itemNumber" }, new int[] { R.id.nameTextView,
									R.id.numberTextView });
					itemListView.setAdapter(listAdapter);
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
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        switch (menuItem.getItemId()) {       	
        //Plus button clicked
        case R.id.newPlusButton:
        	Log.i(TAG, "Plus clicked");
        	Intent newItemIntent = new Intent(MainActivity.this, NewItemActivity.class);
        	startActivity(newItemIntent);
        	break;
        //Log out button
        case R.id.logoutButton:
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
			break;
        default:
			break;
		}
        return super.onOptionsItemSelected(menuItem);
    } //onOptionsItemSelected close
}
