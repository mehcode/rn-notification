import {NativeModules} from "react-native";
const {RNNotification} = NativeModules;

export function create(options = {}) {
  return RNNotification.create(options);
}

export default {
  create,
};
