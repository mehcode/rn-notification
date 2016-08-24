package com.mehcode.reactnative.notification;

import android.support.v7.app.NotificationCompat;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

class NotificationModule extends ReactContextBaseJavaModule {
    public NotificationModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RNNotification";
    }

    @ReactMethod
    public void create(ReadableMap options) {
        NotificationAttributes attributes = NotificationAttributes.fromReadableMap(options);
        Notification notification = new Notification(
            getReactApplicationContext(),
            // Unique ID for notification
            // TODO: Allow specification of this ID
            (int)((new Date().getTime() / 1000L) % Integer.MAX_VALUE),
            attributes
        );

        notification.show();
    }
}
