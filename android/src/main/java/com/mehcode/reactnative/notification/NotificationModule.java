package com.mehcode.reactnative.notification;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v7.app.NotificationCompat;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.Date;

class NotificationModule extends ReactContextBaseJavaModule implements LifecycleEventListener {
    Activity mActivity = null;

    IntentFilter mIntentFilter = new IntentFilter(NotificationEventReceiver.INTENT_ID);
    BroadcastReceiver mIntentReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Bundle extras = intent.getExtras();

            // Focus the application
            String packageName = context.getApplicationContext().getPackageName();
            Intent focusIntent = context.getPackageManager().getLaunchIntentForPackage(packageName).cloneFilter();

            focusIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);

            final Activity activity = getActivity();
            if (activity != null) {
                activity.startActivity(focusIntent);
            }

            // Send event to JS
            WritableMap params = Arguments.createMap();
            params.putInt("id", extras.getInt(NotificationEventReceiver.NOTIFICATION_ID));
            params.putString("payload", extras.getString(NotificationEventReceiver.PAYLOAD));

            getReactApplicationContext()
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("RNNotification:press", params);

            this.setResultCode(Activity.RESULT_OK);
        }
    };

    public NotificationModule(ReactApplicationContext reactContext) {
        super(reactContext);

        reactContext.addLifecycleEventListener(this);
        reactContext.registerReceiver(mIntentReceiver, mIntentFilter);
    }

    @Override
    public String getName() {
        return "RNNotification";
    }

    // Gets the press event that spawned the application, if any
    @ReactMethod
    public void getInitialNotificationPress(Callback cb) {
        final Activity activity = getActivity();
        if (activity == null) return;

        Intent intent = activity.getIntent();
        Bundle extras = intent.getExtras();

        if (extras != null) {
            int initialNotificationId = extras.getInt("RNNotification:initialId", 0);
            if (initialNotificationId != 0) {
                WritableMap params = Arguments.createMap();
                params.putInt("id", initialNotificationId);
                params.putString("payload", extras.getString("RNNotification:initialPayload"));

                cb.invoke(params);
                return;
            }
        }
    }

    @ReactMethod
    public void create(ReadableMap options, ReadableMap payload) {
        NotificationAttributes attributes = NotificationAttributes.fromReadableMap(options);

        Notification notification = new Notification(
                getReactApplicationContext(),

                // Unique ID for notification
                // TODO: Allow specification of this ID
                (int)((new Date().getTime() / 1000L) % Integer.MAX_VALUE),

                // Attributes
                attributes
        );

        notification.show();
    }

    Activity getActivity() {
        Activity activity = getCurrentActivity();
        if (activity == null) activity = mActivity;

        return activity;
    }

    @Override
    public void onHostResume() {
        mActivity = getCurrentActivity();
    }

    @Override
    public void onHostPause() {
        mActivity = getCurrentActivity();
    }

    @Override
    public void onHostDestroy() {
    }
}
