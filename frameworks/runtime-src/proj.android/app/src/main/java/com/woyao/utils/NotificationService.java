package com.woyao.utils;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.app.ActivityManager.RunningTaskInfo;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.ResolveInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.BitmapFactory;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.Toast;

import com.woyao.thai.poker.R;

import org.cocos2dx.lua.AppActivity;

public class NotificationService extends Service
{
    private NotificationManager notificationManager;
    private Notification.Builder mBuilder;
    private Notification notification;

    @Override
    public void onCreate() {
        super.onCreate();
        notificationManager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
        mBuilder = new Notification.Builder(this);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i("NotificationService","onStartCommand");
        Intent intent2=new Intent();
        intent2.setClass(this, AppActivity.class);//点击通知需要跳转的activity
        PendingIntent contentIntent = PendingIntent.getActivity(this,0, intent2,
                PendingIntent.FLAG_UPDATE_CURRENT);
        notification = mBuilder.setContentTitle(intent.getStringExtra("title"))
                .setContentText(intent.getStringExtra("contentText"))
                .setSmallIcon(R.drawable.icon)
                .setLargeIcon(BitmapFactory.decodeResource(this.getResources(), R.drawable.icon))
                .setContentIntent(contentIntent)
                .setDefaults(Notification.DEFAULT_SOUND)
                .build();
        notification.flags |= Notification.FLAG_AUTO_CANCEL;
        notificationManager.notify(0, notification);
        return START_REDELIVER_INTENT;
    }
}
