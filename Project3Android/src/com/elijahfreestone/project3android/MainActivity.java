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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.ActionMode;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.Parse;
import com.parse.ParseACL;
import com.parse.ParseUser;

/**
 * The Class MainActivity.
 */
public class MainActivity extends Activity {
	String TAG = "MainActivity";
	static Context myContext;
	Button logOutButton; 
	static TextView noItemsNotice;
	static ListView itemListView;
	static ArrayList<HashMap<String, String>> parseArrayList;
	static BaseAdapter listAdapter;
	static ActionMode myActionMode;
	int selectedObject = -1;
	View viewSelected;
	String editNameString = "test";
	Boolean networkConnection;

    /* (non-Javadoc)
     * @see android.app.Activity#onCreate(android.os.Bundle)
     */
    @SuppressLint("InflateParams")
	@Override           
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        myContext = this;
        //Request progress wheel
        requestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        
        setContentView(R.layout.activity_main);  
        
        //Check network
        networkConnection = ConnectionManager.connectionStatus(myContext);
        if (!networkConnection) {
        	noConnectionAlert();
		}
        
        //Create no item title
        noItemsNotice = (TextView) findViewById(R.id.noItemsNotice);
        //Grab listview and create header
        itemListView = (ListView) findViewById(R.id.itemListView);
        View listHeader = getLayoutInflater().inflate(R.layout.listview_header, null);
        itemListView.addHeaderView(listHeader);
        
        itemListView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        
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
			//Remove main activity until user is authenticated
			finish();  
		} //currentUser if/else close 

		// Create timer to poll Parse every 20 sec
		final Handler myHandler = new Handler();
		Timer pollTimer = new Timer();
		TimerTask timerTask = new TimerTask() {
			@Override
			public void run() {
				myHandler.post(new Runnable() {
					public void run() {
						//Check network connection and stop query if non
						if (ConnectionManager.connectionStatus(myContext)) {
							// Query Parse to get items list for user and display
							parseArrayList.clear();
							DataManager.queryParseForItems();
							Log.i(TAG, "timer query");
						} else {
							Log.i(TAG, "No connection!!");
						}
					}
				});
			}
		};
		// execute every 20 sec
		pollTimer.schedule(timerTask, 0, 20000);
		
		
		//Set long click listener for listview
		itemListView.setOnItemLongClickListener(new OnItemLongClickListener() {

			@Override
		      public boolean onItemLongClick(AdapterView<?> parent, View view,
		          int position, long id) {
				//Pass view and position to be used elsewhere
				viewSelected = view;
				selectedObject = position;
				//Return if action mode is null for whatever reason
				if (myActionMode != null) {
					Log.i(TAG, "Action mode null!");
		            return false;
		        }
				myActionMode = MainActivity.this.startActionMode(new ActionBarCallBack());
				//viewSelected.setSelected(true);
				//Manually set selected color for list item. Is cleared in CAB destroy
				viewSelected.setBackgroundColor(myContext.getResources().getColor(android.R.color.holo_blue_light)); 
				
		        return true;
		      } 
		}); //setOnItemLongClickListener close
		
    } //onCreate close 

    /* (non-Javadoc)
     * @see android.app.Activity#onCreateOptionsMenu(android.view.Menu)
     */
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true; 
    }

    /* (non-Javadoc)
     * @see android.app.Activity#onOptionsItemSelected(android.view.MenuItem)
     */
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
        	//Log user out and present login screen
			ParseUser.logOut();
			Log.i(TAG, "User logged out");
			Intent logoutIntent = new Intent(MainActivity.this, LoginAndSignupActivity.class);
			startActivity(logoutIntent);
			Toast.makeText(getApplicationContext(), "You have been successfully logged out.",
                    Toast.LENGTH_LONG).show();
			//Remove Main activity from stack to stop "Back button login"
			finish(); 
			break;
		//Refresh button
		case R.id.refreshButton:
			Log.i(TAG, "Refresh hit");
			//Clear arraylist and query Parse again
			parseArrayList.clear();
			DataManager.queryParseForItems();
			break;
        default:  
			break;
		}
        return super.onOptionsItemSelected(menuItem);
    } //onOptionsItemSelected close
    
    /* (non-Javadoc)
     * @see android.app.Activity#onActivityResult(int, int, android.content.Intent)
     */
    @Override 
    protected void onActivityResult(int requestCode, int resultCode, Intent newItemBackIntent) {
    	Log.i(TAG, "On Activity Result");
    	if (resultCode == RESULT_OK && requestCode == 0) {
    		Log.i(TAG, "Result Code OK");
    		parseArrayList.clear();
    		//listAdapter.notifyDataSetInvalidated();
			DataManager.queryParseForItems();
			DataManager.listAdapter.notifyDataSetChanged();
		}
    	//super.onActivityResult(requestCode, resultCode, newItemBackIntent);
    } //onActivityResult close
    
    /**
     * The Class ActionBarCallBack handles contextual action bar for edit and delete of items.
     */
    class ActionBarCallBack implements ActionMode.Callback {
    	  
        /* (non-Javadoc)
         * @see android.view.ActionMode.Callback#onActionItemClicked(android.view.ActionMode, android.view.MenuItem)
         */
        @Override
        public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
            switch (item.getItemId()) { 
			case R.id.editItem:
				int newSelectedObject = selectedObject - 1;
				Log.i(TAG, "Edit: " + parseArrayList.get(newSelectedObject));
				String editNameString = parseArrayList.get(newSelectedObject).get("itemName");
				String editNumberString = parseArrayList.get(newSelectedObject).get("itemNumber");
				String editItemID = parseArrayList.get(newSelectedObject).get("itemID");
				
				Intent editIntent = new Intent(MainActivity.this, NewItemActivity.class);
				editIntent.putExtra("itemName", editNameString);
				editIntent.putExtra("itemNumber", editNumberString);
				editIntent.putExtra("itemID", editItemID);
				startActivityForResult(editIntent, 0);
				myActionMode.finish();
				break;
			case R.id.deleteItem:
				Log.i(TAG, "Delete clicked");
				DataManager.deleteItem(selectedObject);
				break; 
			default:
				break;
			}
            return false;
        }
  
        /* (non-Javadoc)
         * @see android.view.ActionMode.Callback#onCreateActionMode(android.view.ActionMode, android.view.Menu)
         */
        @Override
        public boolean onCreateActionMode(ActionMode mode, Menu menu) {
            // TODO Auto-generated method stub
            mode.getMenuInflater().inflate(R.menu.contextual_action_bar, menu);
            return true;
        }
   
        /* (non-Javadoc)
         * @see android.view.ActionMode.Callback#onDestroyActionMode(android.view.ActionMode)
         */
        @Override
        public void onDestroyActionMode(ActionMode mode) {
            // TODO Auto-generated method stub
        	myActionMode = null;
        	selectedObject = -1;
        	viewSelected.setBackgroundColor(Color.TRANSPARENT);
        	//Log.i(TAG, "selectedObject = " + selectedObject);
        }
  
        /* (non-Javadoc)
         * @see android.view.ActionMode.Callback#onPrepareActionMode(android.view.ActionMode, android.view.Menu)
         */
        @Override
        public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
            // TODO Auto-generated method stub
  
            mode.setTitle("Edit/Delete");
            return false;
        }
    } //ActionBarCallBack close
    
	/*
	 * Custom method to show no connection alert
	 */
	public static void noConnectionAlert() {
		// Create alert dialog for no connection
		AlertDialog alertDialog = new AlertDialog.Builder(
				MainActivity.myContext).create();
		alertDialog.setTitle(R.string.noConnectionTitle);
		// Set alert message. setMessage only has a charSequence
		// version so getString must be used.
		alertDialog.setMessage(myContext.getString(R.string.noConnectionAlert));
		alertDialog.setButton(DialogInterface.BUTTON_POSITIVE, "OK",
				(DialogInterface.OnClickListener) null);
		alertDialog.show();
	} //noConnectionAlert close
    
}
