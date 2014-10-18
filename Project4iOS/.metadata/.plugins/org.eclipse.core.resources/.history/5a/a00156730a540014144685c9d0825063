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

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * The Class Connection Manager tests for network connection.
 */
public class ConnectionManager {
	static String responseString;

	/**
	 * Connection status.
	 * 
	 * @param myContext the my context
	 * @return the boolean
	 */
	public static Boolean connectionStatus(Context myContext) {
		Boolean connectionBool = false;
		ConnectivityManager connectionManager = (ConnectivityManager) myContext
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo networkInfo = connectionManager.getActiveNetworkInfo();
		if (networkInfo != null) {
			if (networkInfo.isConnected()) {
				connectionBool = true;
			}
		}
		return connectionBool;
	} // connectionStatus Close
}
