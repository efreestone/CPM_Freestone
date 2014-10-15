/*
 * @author	Elijah Freestone 
 *
 * Project	Project3Android
 * 
 * @class 	CPM term 1410
 * 
 * Package	com.elijahfreestone.project3android
 * 
 * Date		Oct 14, 2014
 */

package com.elijahfreestone.project3android;

import com.parse.Parse;

import android.app.Application;

public class ParseInitialization extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
		
		Parse.enableLocalDatastore(this);
        //Initialize Parse with credentials 
        Parse.initialize(this, "SAUIZr14D78N6VQVjYfu6KJmNzALl1YE4BCvcq8S", "TCdRBe56XyyV2ra4BBOzfafYsy8dWImtCGlZTWu4");
	}

}
