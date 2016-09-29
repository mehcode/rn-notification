import {
  NativeModules,
  DeviceEventEmitter,
  Platform,
} from "react-native";

const {
  RNNotification
} = NativeModules;

const pressListeners = [];
const tokenListeners = [];

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

DeviceEventEmitter.addListener("RNNotification:registration", (token) => {
  // Emit
  for (const listener of tokenListeners) {
    listener(token);
  }
});

export default {
  // Request permissions
  requestPermission() {
    if (Platform.OS === "android") {
      // nop
      return;
    }

    return RNNotification.requestPermission();
  },

  // Create (local) notification
  create(options = {}, payload = {}) {
    return RNNotification.create(options, payload);
  },

  // Remove listener
  removeListener(listener) {
    let index;

    index = tokenListeners.indexOf(listener);
    if (index >= 0) tokenListeners.splice(index, 1);

    index = pressListeners.indexOf(listener);
    if (index >= 0) pressListeners.splice(index, 1);
  },

  // Add listener (remote/local)
  addListener(kind, listener) {
    switch (kind) {
      case "registration":
        // Token registration
        tokenListeners.push(listener);

        // Emit the initial token
        RNNotification.getRegistrationToken().then((token) => {
          listener(token);
        });

        break;

      case "press":
        // Register listener for normal press events
        pressListeners.push(listener);

        // Emit the initial notification press
        if (!presentedInitialNotificationPress) {
          RNNotification.getInitialNotificationPress((event) => {
            listener(formatPressEvent(event));
          });

          presentedInitialNotificationPress = true;
        }

        break;
    }
  }
};
