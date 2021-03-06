/**
 * Copyright (c) 2013 DuoKu Inc.
 */
package com.haowan123.kof.bd;

import android.app.Activity;
import android.app.ProgressDialog;

public class BaseActivity extends Activity{
	private ProgressDialog progressDialog;
    
	protected void showLoading(){
		progressDialog = new ProgressDialog(this);
		progressDialog.setMessage("正在加载...");
		progressDialog.setIndeterminate(true);
		progressDialog.setCancelable(false);
		progressDialog.show();
	}
    
	protected void showLoading(String tips){
		progressDialog = new ProgressDialog(this);
		progressDialog.setMessage(tips);
		progressDialog.setIndeterminate(true);
		progressDialog.setCancelable(false);
		progressDialog.show();
	}
    
	protected void hideLoading(){
		if(progressDialog != null){
			progressDialog.cancel();
			progressDialog = null;
		}
	}
}
