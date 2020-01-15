import { EventEmitter, NativeModulesProxy } from '@unimodules/core';
// Web uses SyntheticEventEmitter
const emitter = new EventEmitter(NativeModulesProxy.ExpoNotificationsEmitter);
const didReceiveNotificationEventName = 'onDidReceiveNotification';
export function addNotificationListener(listener) {
    return emitter.addListener(didReceiveNotificationEventName, listener);
}
export function removeNotificationSubscription(subscription) {
    emitter.removeSubscription(subscription);
}
export function removeAllNotificationListeners() {
    emitter.removeAllListeners(didReceiveNotificationEventName);
}
//# sourceMappingURL=NotificationsEmitter.js.map