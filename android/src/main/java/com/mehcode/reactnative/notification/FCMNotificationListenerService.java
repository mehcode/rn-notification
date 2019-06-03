package com.mehcode.reactnative.notification;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;
import java.util.Iterator;
import java.util.Map;

public class FCMNotificationListenerService extends FirebaseMessagingService {
    final static String INSTANCE_ID_INTENT_ID = "com.mehcode.reactnative.notification.FCMInstanceIDEvent";

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. This call is initiated by the
     * InstanceID provider.
     */
    @Override
    public void onNewToken(String refreshedToken) {
        // Broadcast refreshed token
        Intent i = new Intent(INTENT_ID);
        Bundle bundle = new Bundle();
        bundle.putString("token", refreshedToken);
        i.putExtras(bundle);
        sendBroadcast(i);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // TODO: General notification event

        Map<String, String> data = remoteMessage.getData();
        String notificationRawText = data.get("notification");
        if (notificationRawText != null) {
            JSONObject notificationJson;
            try {
                // Handle and consume notification
                notificationJson = new JSONObject(notificationRawText);
            } catch (JSONException e) {
                e.printStackTrace();
                return;
            }

            // Convert to WritableMap
            WritableMap m = new WritableNativeMap();
            for (Iterator<String> it = notificationJson.keys(); it.hasNext();) {
                String key = it.next();

                // Boolean

                try {
                    Boolean value = notificationJson.getBoolean(key);
                    m.putBoolean(key, value);

                    continue;
                } catch (JSONException e) {
                    // Do nothing
                }

                // Integer

                try {
                    Integer value = notificationJson.getInt(key);
                    m.putInt(key, value);

                    continue;
                } catch (JSONException e) {
                    // Do nothing
                }

                // Double

                try {
                    Double value = notificationJson.getDouble(key);
                    m.putDouble(key, value);

                    continue;
                } catch (JSONException e) {
                    // Do nothing
                }

                // String

                try {
                    String value = notificationJson.getString(key);
                    m.putString(key, value);

                    continue;
                } catch (JSONException e) {
                    // Do nothing
                }
            }

            // Create and show notification
            NotificationAttributes attributes = NotificationAttributes.fromReadableMap(m);
            Notification notification = new Notification(
                    this,

                    // Unique ID for notification
                    // TODO: Allow specification of this ID
                    (int)((new Date().getTime() / 1000L) % Integer.MAX_VALUE),

                    // Attributes
                    attributes
            );

            notification.show();
        }
    }
}
