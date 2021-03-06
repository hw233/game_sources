package com.haowan123.kof.bd;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.lang.Thread.UncaughtExceptionHandler;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import com.duoku.platform.demo.utils.MyLogger;
import com.duoku.platform.demo.utils.PhoneHelper;

import android.content.Context;
import android.os.Environment;

public class CrashHandler implements UncaughtExceptionHandler {
    private static MyLogger mLogger = MyLogger.getLogger(CrashHandler.class.getName());
    
    // 系统默认的UncaughtException处理类
    private Thread.UncaughtExceptionHandler mDefaultHandler;
    // CrashHandler实例
    private static CrashHandler INSTANCE = new CrashHandler();
    // 程序的Context对象
    private Context mContext;
    // 用来存储设备信息和异常信息
    private Map<String, String> infos = new HashMap<String, String>();
    
    // 用于格式化日期,作为日志文件名的一部分
    private DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
    
    /** 保证只有一个CrashHandler实例 */
    private CrashHandler() {
    }
    
    /** 获取CrashHandler实例 ,单例模式 */
    public static CrashHandler getInstance() {
        return INSTANCE;
    }
    
    /**
     * 初始化
     *
     * @param context
     */
    public void init(Context context) {
        mContext = context;
        mLogger.d("CrashHandler init isEmulator = "+PhoneHelper.isEmulator(mContext));
        if (!PhoneHelper.isEmulator(mContext)) {
            // 获取系统默认的UncaughtException处理器
            mDefaultHandler = Thread.getDefaultUncaughtExceptionHandler();
            // 设置该CrashHandler为程序的默认处理器
            Thread.setDefaultUncaughtExceptionHandler(this);
        }
    }
    
    /**
     * 当UncaughtException发生时会转入该函数来处理
     */
    public void uncaughtException(Thread thread, Throwable ex) {
        //    	DownLoadController.cancelAllDownloadTask();
        //        if (!handleException(ex) && mDefaultHandler != null) {
        //            // 如果用户没有处理则让系统默认的异常处理器来处理
        //            mDefaultHandler.uncaughtException(thread, ex);
        //        }
    }
    
    /**
     * 自定义错误处理,收集错误信息 发送错误报告等操作均在此完成.
     *
     * @param ex
     * @return true:如果处理了该异常信息;否则返回false.
     */
    private boolean handleException(Throwable ex) {
        // 保存日志文件
        saveCrashInfo2File(ex);
        return true;
    }
    
    /**
     * 保存错误信息到文件中
     *
     * @param ex
     * @return 返回文件名称,便于将文件传送到服务器
     */
    private String saveCrashInfo2File(Throwable ex) {
        
		StringBuffer sb = new StringBuffer();
		for (Map.Entry<String, String> entry : infos.entrySet()) {
			String key = entry.getKey();
			String value = entry.getValue();
			sb.append(key + "=" + value + "\n");
		}
        
		Writer writer = new StringWriter();
		PrintWriter printWriter = new PrintWriter(writer);
		ex.printStackTrace(printWriter);
		Throwable cause = ex.getCause();
		while (cause != null) {
			cause.printStackTrace(printWriter);
			cause = cause.getCause();
		}
		printWriter.close();
		String result = writer.toString();
		sb.append(result);
		try {
			long timestamp = System.currentTimeMillis();
			Calendar myDate = Calendar.getInstance();
			StringBuffer date = new StringBuffer();
			date.append(myDate.get(Calendar.YEAR)).append("-").append(myDate.get(Calendar.MONTH)).append("-").append(myDate.get(Calendar.DAY_OF_MONTH)).append("-")
            .append(myDate.get(Calendar.HOUR)).append("-").append(myDate.get(Calendar.MINUTE)).append("-").append(myDate.get(Calendar.SECOND));
            //			String time = formatter.format(new Date());
            
			String fileName = "crash-" + date.toString()  + "-" + timestamp + ".log";
			if (Environment.getExternalStorageState().equals(
                                                             Environment.MEDIA_MOUNTED)) {
				String path = Environment.getExternalStorageDirectory()
                .toString() + GAMESDK_LOG;
				File dir = new File(path);
				if (!dir.exists()) {
					dir.mkdirs();
				}
				FileOutputStream fos = new FileOutputStream(path + fileName);
				fos.write(sb.toString().getBytes());
				fos.close();
			}
			return fileName;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
    
    public static final String GAMESDK_LOG  = "/duokugamesdk/crashlog/";
}