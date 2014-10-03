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

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.ActionMode;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast; 

import com.parse.DeleteCallback;
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
	static ListView itemListView;
	ArrayList<HashMap<String, String>> parseArrayList;
	BaseAdapter listAdapter;
	Object myActionMode;
	int itemSelected = -1;

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
		
		//Set long click lsitener for listview
		itemListView.setOnItemLongClickListener(new OnItemLongClickListener() {

			@Override
		      public boolean onItemLongClick(AdapterView<?> parent, View view,
		          int position, long id) {
				deleteItem(position);
		        return true;
		      }
		}); //setOnItemLongClickListener close
		
    } //onCreate close 
    
    void deleteItem(int positionSelected) {
    	final int deleteItemPosition = positionSelected;
    	//Create dialog to confirm delete
    	AlertDialog.Builder deleteDialog = new AlertDialog.Builder(MainActivity.this);
    	deleteDialog.setTitle("Delete Item?");
    	deleteDialog.setMessage("Are you sure you want to delete this item?");
    	deleteDialog.setPositiveButton("YES", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				//Remove item from listview
				ParseQuery<ParseObject> deleteQuery = ParseQuery.getQuery("newItem");
				deleteQuery.findInBackground(new FindCallback<ParseObject>() {

					@Override
					public void done(List<ParseObject> itemsList, ParseException e) {
						if (e == null) {
							//Delete item from parse
							itemsList.get(deleteItemPosition).deleteInBackground(new DeleteCallback() {

								@Override
								public void done(ParseException arg0) {
									if (arg0 == null) {
										Toast.makeText(getBaseContext(),"Item Successfully Deleted!", Toast.LENGTH_LONG).show();
										//Clear item arraylist and repop listview
										parseArrayList.clear();
										queryParseForItems();
										
									} else {
										Toast.makeText(getBaseContext(),"An error occured, please try again.", Toast.LENGTH_LONG).show();
									}
								}
							}); //deleteInBackground close
						}
					}
				}); //findInBackground close
				
			}
		});
    	deleteDialog.setNegativeButton("NO", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				// TODO Auto-generated method stub
				
			}
		}); 
    	
    	deleteDialog.show();
    	
    }
    
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
					listAdapter = new SimpleAdapter(
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
        	startActivityForResult(newItemIntent, 0);
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
    
	//Called when a a contextual menu item is selected
	public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
		switch (item.getItemId()) {
		case R.id.showMenuItem:
			
			//Action executed, close the CAB
			mode.finish();
			return true;
		default:
			return false;
		}
	} //onActionItemClicked close
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent newItemBackIntent) {
    	Log.i(TAG, "On Activity Result");
    	if (resultCode == RESULT_OK && requestCode == 0) {
    		Log.i(TAG, "Result Code OK");
    		parseArrayList.clear();
    		//listAdapter.notifyDataSetInvalidated();
			queryParseForItems();
		}
    	//super.onActivityResult(requestCode, resultCode, newItemBackIntent);
    }
}
