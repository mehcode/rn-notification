package com.mehcode.reactnative.notification;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;

public class FCMInstanceIDService extends FirebaseInstanceIdService {
    final static String INTENT_ID = "com.mehcode.reactnative.notification.FCMInstanceIDEvent";

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. This call is initiated by the
     * InstanceID provider.
     */
    @Override
    public void onTokenRefresh() {
        // Get updated InstanceID token.
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();

        // Broadcast refreshed token
        Intent i = new Intent(INTENT_ID);
        Bundle bundle = new Bundle();
        bundle.putString("token", refreshedToken);
        i.putExtras(bundle);
        sendBroadcast(i);
    }
}
