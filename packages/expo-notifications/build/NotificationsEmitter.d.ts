import { Subscription } from '@unimodules/core';
declare type Notification = any;
export declare type NotificationListener = (notification: Notification) => void;
export declare function addNotificationListener(listener: NotificationListener): Subscription;
export declare function removeNotificationSubscription(subscription: Subscription): void;
export declare function removeAllNotificationListeners(): void;
export {};
