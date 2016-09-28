import {
  NativeModules,
  DeviceEventEmitter,
  Platform,
} from "react-native";

const {
  RNNotification
} = NativeModules;

const pressListeners = [];

// True if we've emitted the initial notification press
// that opened this activity
let presentedInitialNotificationPress = false;

function formatPressEvent(event) {
  try {
    event.payload = JSON.parse(event.payload || "");
  } catch (err) {
    event.payload = {};
  }

  return event;
}

DeviceEventEmitter.addListener("RNNotification:press", (nativeEvent) => {
  // Format event
  const event = formatPressEvent(nativeEvent);

  // Emit
  for (const listener of pressListeners) {
    listener(event);
  }
});

export default {
  // Request permissions
  requestPermissions() {
    if (Platform.OS === "android") {
      // nop
      return;
    }

    return RNNotification.requestPermissions();
  },

  // Create (local) notification
  create(options = {}, payload = {}) {
    return RNNotification.create(options, payload);
  },

  // Add listener (remote/local)
  addListener(kind, listener) {
    switch (kind) {
      case "press":
        // Register listener for normal press events
        pressListeners.push(listener);

        // Emit the initial notification press
        if (!presentedInitialNotificationPress) {
          RNNotification.getInitialNotificationPress((event) => {
            listener(formatPressEvent(event));
          });
        }

        break;
    }
  }
};
