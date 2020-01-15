import { EventEmitter, Subscription, NativeModulesProxy } from '@unimodules/core';

type Notification = any;
export type NotificationListener = (notification: Notification) => void;

// Web uses SyntheticEventEmitter
const emitter = new EventEmitter(NativeModulesProxy.ExpoNotificationsEmitter);
const didReceiveNotificationEventName = 'onDidReceiveNotification';

export function addNotificationListener(listener: NotificationListener): Subscription {
  return emitter.addListener(didReceiveNotificationEventName, listener);
}

export function removeNotificationSubscription(subscription: Subscription) {
  emitter.removeSubscription(subscription);
}

export function removeAllNotificationListeners() {
  emitter.removeAllListeners(didReceiveNotificationEventName);
}
