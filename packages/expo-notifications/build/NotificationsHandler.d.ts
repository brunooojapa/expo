import { NotificationBehavior } from './NotificationsHandlerModule';
declare type Notification = any;
export interface NotificationDelegate {
    handleNotification: (notification: Notification) => Promise<NotificationBehavior>;
    handleSuccess?: (notificationId: string) => void;
    handleError?: (error: Error) => void;
}
export declare function setNotificationDelegate(delegate: NotificationDelegate): void;
export {};
