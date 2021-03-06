package com.haowan123.kof.bd;

import com.ptola.GameUserData;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import com.ptola.GameUserData;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;
import com.duoku.platform.DkErrorCode;
import com.duoku.platform.DkPlatform;
import com.duoku.platform.DkPlatformSettings;
import com.duoku.platform.DkPlatformSettings.GameCategory;
import com.duoku.platform.DkProCallbackListener.OnLoginProcessListener;
import com.haowan123.kof.bd.R;
import com.duoku.platform.demo.utils.Constant;
import com.duoku.platform.entry.DkBaseUserInfo;
/**
 * Welcome Activity
 */

public class StartupActivity extends BaseActivity
{
	@Override
	public void onCreate(Bundle savedInstanceState) {
	    super.onCreate(savedInstanceState);
	    this.setContentView(R.layout.bg);
        //	    findViewById(R.id.btn_layout).setVisibility(View.VISIBLE);
        
		//特别注意：请在onCreate中进行初始化，在游戏主activity中的onDestory中进行资源释放，详情请参照本activity的onDestory方法，如不释放会出现crash等问题。
		DkPlatformSettings appInfo = new DkPlatformSettings();
		appInfo.setGameCategory(GameCategory.ONLINE_Game);
		appInfo.setmAppid(Constant.appId_DkDemo);//应用ID，由多酷分配
		appInfo.setmAppkey(Constant.appKey_DkDemo);//应用Key，由多酷分配
        
		DkPlatform.getInstance().init(getApplicationContext(), appInfo); //初始化多酷SDK
		
		initApp();
		accountLogin();
	}
	
	private void initApp() {
        //		 设置SDK的横竖屏显示
		int orient = DkPlatformSettings.SCREEN_ORIENTATION_LANDSCAPE;
        //		int orient = DkPlatformSettings.SCREEN_ORIENTATION_PORTRAIT;
		DkPlatform.getInstance().dkSetScreenOrientation(orient);
	}
	
	/**
	 * 帐号登录
	 *
	 */
	private void accountLogin() {
		
		DkPlatform.getInstance().dkLogin(this, new OnLoginProcessListener() {
			
			@Override
			public void onLoginProcess(int paramInt) {
				// TODO Auto-generated method stub
				
				switch (paramInt) {
                    case DkErrorCode.DK_LOGIN_SUCCESS: {
                        Toast.makeText(StartupActivity.this, "登录成功", Toast.LENGTH_LONG).show();
                        StartupActivity.this.finish();
                        Intent intent = new Intent(StartupActivity.this, com.haowan123.kof.bd.GameBox.class);
                        
                        //Caution： 此处请勿使用username去标识用户，一定要使用uid去标识用户，否则造成用户损失，后果自负
                        DkBaseUserInfo baseInfo = DkPlatform.getInstance().dkGetMyBaseInfo(StartupActivity.this);
                        String uid = baseInfo.getUid();
                        GameUserData.setValue("userName", uid);
                        startActivity(intent);
                        break;
                    }
                    case DkErrorCode.DK_LOGIN_CANCELED: {
                        Toast.makeText(StartupActivity.this, "用户取消登录", Toast.LENGTH_LONG).show();
                        
                        break;
                    }
                    default:
                        break;
				}
			}
		});
	}
    
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
        //		DkPlatform.getInstance().dkReleaseResource(this);
	}
    
	protected void onActivityResult(int requestCode, int resultCode,Intent data)
	{
        //		if( requestCode == requestCode_wws )
        //		{
        //			if( resultCode == com.wws.sdk.WwsLoginActivity.WWS_SDK_Longin_RESOUT )
        //			{
        //				Bundle bundle = data.getExtras();
        //				String userName= bundle.getString("userName");
        //				String time= bundle.getString("time");
        //				String url = bundle.getString("url");
        //				String stata = bundle.getString("stata");
        //                String serverData= bundle.getString("serverData");
        //                Log.i("TAG","---->"+userName+":"+time+":"+url+":"+stata+":"+serverData);
        //                this.finish();
        //                GameUserData.setValue("userName", userName);
        //                Intent cc2dContext = new Intent(this, com.haowan123.kof123baidu.GameBox.class);
        //                startActivity(cc2dContext);
        //			}
        //		}
        //
        //		super.onActivityResult(requestCode, resultCode, data);
	}
}