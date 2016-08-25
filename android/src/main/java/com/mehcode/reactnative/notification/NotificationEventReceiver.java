package com.mehcode.reactnative.notification;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

public class NotificationEventReceiver extends BroadcastReceiver {
    final static String INTENT_ID = "com.mehcode.reactnative.notification.NotificationEvent";
    final static String NOTIFICATION_ID = "id";
    final static String PAYLOAD = "payload";

    @Override
    public void onReceive(Context context, Intent intent) {
        sendBroadcast(context, intent.getExtras());
    }

    void sendBroadcast(final Context context, final Bundle extras) {
        Intent intent = new Intent(INTENT_ID);

        intent.putExtra("id", extras.getInt(NOTIFICATION_ID));
        intent.putExtra("payload", extras.getString(PAYLOAD));

        context.sendOrderedBroadcast(intent, null, new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int result = getResultCode();

                if (result != Activity.RESULT_OK) {
                    launchApplication(context, extras);
                }
            }
        }, null, Activity.RESULT_CANCELED, null, null);
    }

    void launchApplication(final Context context, final Bundle extras) {
        String packageName = context.getApplicationContext().getPackageName();
        Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);

        launchIntent.putExtra("RNNotification:initialId", extras.getInt(NOTIFICATION_ID));
        launchIntent.putExtra("RNNotification:initialPayload", extras.getString(PAYLOAD));
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        context.startActivity(launchIntent);
    }
}
