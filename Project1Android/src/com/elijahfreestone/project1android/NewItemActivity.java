/*
 * @author	Elijah Freestone 
 *
 * Project	Project1Android
 * 
 * @class 	CPM term 1410
 * 
 * Package	com.elijahfreestone.project1android
 * 
 * Date		Sep 30, 2014
 */

package com.elijahfreestone.project1android;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.SaveCallback;

public class NewItemActivity extends Activity {
	String TAG = "NewItemActivity";
	EditText nameEditText;
	EditText numberEditText;
	Button saveButton;
	String nameEntered;
	String numberEnteredString;
	int numberEnteredInt; 
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_new_item);  
		
		//Grab edit texts and button
		nameEditText = (EditText) findViewById(R.id.nameEditText);
		numberEditText = (EditText) findViewById(R.id.numberEditText);
		saveButton = (Button) findViewById(R.id.saveButton);
		
		saveButton.setOnClickListener(new OnClickListener() { 
			
			@Override 
			public void onClick(View arg0) {
				nameEntered = nameEditText.getText().toString();
				numberEnteredString = numberEditText.getText().toString();
				
				//Check that both fields contain data
				if (nameEntered.equals("") || numberEnteredString.equals("")) {
					Toast.makeText(getApplicationContext(), "Both fields are required to save",
							Toast.LENGTH_LONG).show();
				} else {
					//Parse int from number string
					numberEnteredInt = Integer.parseInt(numberEnteredString);
					Log.i(TAG, "Save clicked");
					Log.i(TAG, "Name: " + nameEntered + "\nNumber: " + numberEnteredInt);

					// Save new item to Parse. Default ACL is set in MainActivity
					ParseObject newItem = new ParseObject("newItem");
					newItem.put("Name", nameEntered);
					newItem.put("Number", numberEnteredInt);
					newItem.saveInBackground(new SaveCallback() {
						
						@Override
						public void done(ParseException arg0) {
							if (arg0 == null) {
								Toast.makeText(getApplicationContext(), "Item Saved!",
										Toast.LENGTH_LONG).show();
								finish();
							} else {
								Toast.makeText(getApplicationContext(), "An error occured, please try again",
										Toast.LENGTH_LONG).show();
							}
						}
					}); //saveInBackground close
				}
			} 
		}); //setOnClickListener close
	} //onCreate close 

}
