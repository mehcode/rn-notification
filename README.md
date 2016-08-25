# React Native Notification
> React Native Cross-Platform Remote and Local Notifications

## Features
 * Local (from JavaScript)
 * Remote (from Push API)
 * 100% Support for all Application States (background, foreground, killed, etc.)
 * Supports FCM (which can be used with GCM API)

## Install

```sh
$ npm i rn-notification --save
$ react-native link rn-notification
```

## Configure

 - [Android](./docs/android.md)
 - [iOS](./docs/ios.md)

## Usage

### Create (Local)
Create local notification.

```js
import Notification from "rn-notification";

Notification.create({
  subject: "Biltong",
  message: "Bacon ipsum dolor amet corned beef biltong picanha sirloin rump tail tongue, jowl kevin ham hock strip steak pastrami kielbasa.",
  priority: "high",
  color: "#DE3226",
  sound: "alert",
  smallIcon: "ic_launcher",
  payload: {
    random: Math.random(),
  }
});
```

### Action (Local and Remote)
Respond to taps from a remote or local notification.

The callback is invoked regardless of where the notification came
from (remote or local) or what state the
application is in when it received the
notification (dead, background, foreground).

```js
import Notification from "rn-notification";

Notification.on("press", (token) => {
  // Invoked when notification is pressed regardless of when it is
  // pressed (foreground, background, in space, etc.)
});
```
