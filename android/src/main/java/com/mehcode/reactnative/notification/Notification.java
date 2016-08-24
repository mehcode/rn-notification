package com.mehcode.reactnative.notification;

import android.support.v7.app.NotificationCompat;

import android.content.Context;

class Notification {
    int mId;
    Context mContext;
    NotificationAttributes mAttributes;

    public Notification(Context context, int id, NotificationAttributes attributes) {
      mContext = context;
      mId = id;
      mAttributes = attributes;
    }

    public void show() {
      getNotificationManager().notify(mId, build());
    }

    android.app.Notification build() {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(
            mContext);

        builder.setContentTitle(mAttributes.subject);
        builder.setContentText(mAttributes.message);
    }
}
