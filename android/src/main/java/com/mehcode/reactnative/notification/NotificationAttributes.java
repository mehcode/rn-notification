package com.mehcode.reactnative.notification;

import android.support.v7.app.NotificationCompat;

class NotificationAttributes {
    // Maps to `notification#title`
    public String subject;

    // Maps to `notification#body`
    public String message;

    public static NotificationAttributes fromReadableMap(ReadableMap m) {
      if (m.hasKey("subject")) subject = m.getString("subject");
      if (m.hasKey("body")) body = m.getString("body");
    }
}
