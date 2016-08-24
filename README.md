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
});
```

### Register (Remote)
Register device to receive notifications.

```js
import Notification from "rn-notification";

Notification.on("token", (token) => {
  // Invoked immediately for initial registration to get the initial token
  // Invoked by Firebase if it feels it wants to give you a new token
});
```

### Action (Local and Remote)
Respond to taps from the notification.

```js
import Notification from "rn-notification";

Notification.on("press", (token) => {
  // Invoked when notification is pressed regardless of when it is
  // pressed (foreground, background, in space, etc.)
});
```
