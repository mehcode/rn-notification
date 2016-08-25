package com.mehcode.reactnative.notification;

import android.support.v7.app.NotificationCompat;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.ReadableType;

import org.json.JSONObject;

import java.util.HashMap;

class NotificationAttributes {
    // Maps to `@notification#title`
    public String subject;

    // Maps to `@notification#body`
    public String message;

    // Maps to `@notification#icon`
    public String smallIcon;

    // Maps to `@priority`
    //  low => -2
    //  normal => 0
    //  high => 2
    public String priority;

    // Maps to `@notification#color`
    // Color behind smallIcon in notification drawer
    public String color;

    // Maps to `@notification#sound`
    // TODO: Not Implemented
    public String sound;

    // Maps to `setVibrate`
    // TODO: Not Implemented
    public String vibrate;

    // Maps to `setLights`
    // TODO: Not Implemented
    public String lights;

    // Payload received via JS on press of notification.
    // JSON string is parsed before going to JS event.
    public String payload;

    public NotificationAttributes() {
        subject = "";
        message = "";
        smallIcon = "ic_launcher";
        priority = "normal";
        sound = "default";
        vibrate = "default";
        lights = "default";
        payload = "{}";
    }

    public static NotificationAttributes fromReadableMap(ReadableMap m) {
        NotificationAttributes r = new NotificationAttributes();

        if (m.hasKey("subject")) r.subject = m.getString("subject");
        if (m.hasKey("message")) r.message = m.getString("message");
        if (m.hasKey("smallIcon")) r.smallIcon = m.getString("smallIcon");
        if (m.hasKey("priority")) r.priority = m.getString("priority");
        if (m.hasKey("sound")) r.sound = m.getString("sound");
        if (m.hasKey("vibrate")) r.vibrate = m.getString("vibrate");
        if (m.hasKey("lights")) r.lights = m.getString("lights");
        if (m.hasKey("color")) r.color = m.getString("color");

        if (m.hasKey("payload")) {
            if (m.getType("payload") == ReadableType.Map) {
                // Serialize payload as JSON
                ReadableMap payloadRM = m.getMap("payload");
                HashMap<String, Object> payloadM = ((ReadableNativeMap)payloadRM).toHashMap();
                JSONObject payloadJson = new JSONObject(payloadM);

                r.payload = payloadJson.toString();
            } else if (m.getType("payload") == ReadableType.String) {
                r.payload = m.getString("payload");
            }
        }

        return r;
    }
}
