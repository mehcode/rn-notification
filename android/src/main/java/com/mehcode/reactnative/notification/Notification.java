package com.mehcode.reactnative.notification;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.support.v7.app.NotificationCompat;

import android.content.Context;

import org.json.JSONObject;

import java.util.HashMap;

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

        // Click action (open app)
        builder.setContentIntent(getIntent());

        // Defaults (sound, lights, vibrate)
        int defaults = 0;
        if (mAttributes.sound.equals("default")) {
            defaults = defaults | android.app.Notification.DEFAULT_SOUND;
        }
        if (mAttributes.vibrate.equals("default")) {
            defaults = defaults | android.app.Notification.DEFAULT_VIBRATE;
        }
        if (mAttributes.lights.equals("default")) {
            defaults = defaults | android.app.Notification.DEFAULT_LIGHTS;
        }
        builder.setDefaults(defaults);

        // AutoCancel (clear on press)
        // TODO: Make configurable
        builder.setAutoCancel(true);

        // Subject, Message, and SmallIcon
        builder.setContentTitle(mAttributes.subject);
        builder.setContentText(mAttributes.message);

        builder.setSmallIcon(mContext.getResources().getIdentifier(
                mAttributes.smallIcon, "mipmap", mContext.getPackageName()));

        // Priority
        int nPriority = 0;
        if (mAttributes.priority.equals("high")) nPriority = NotificationCompat.PRIORITY_MAX;
        else if (mAttributes.priority.equals("low")) nPriority = NotificationCompat.PRIORITY_MIN;

        builder.setPriority(nPriority);

        // Color (behind small icon in drawer)
        if (mAttributes.color != null) {
            builder.setColor(Color.parseColor(mAttributes.color));
        }

        // Sound
        if (!mAttributes.sound.equals("default")) {
            int soundId = mContext.getResources().getIdentifier(
                    mAttributes.sound, "raw", mContext.getPackageName());

            Uri soundUri = Uri.parse(
                    "android.resource://" + mContext.getPackageName() + "/" + soundId);

            builder.setSound(soundUri);
        }

        return builder.build();
    }

    NotificationManager getNotificationManager() {
        return (NotificationManager)mContext.getSystemService(Context.NOTIFICATION_SERVICE);
    }

    PendingIntent getIntent() {
        Intent intent = new Intent(mContext, NotificationEventReceiver.class);

        intent.putExtra(NotificationEventReceiver.NOTIFICATION_ID, mId);
        intent.putExtra(NotificationEventReceiver.PAYLOAD, mAttributes.payload);

        return PendingIntent.getBroadcast(mContext, mId, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }
}
