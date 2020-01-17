import { EventEmitter, Subscription, CodedError } from '@unimodules/core';
import NotificationsHandlerModule, { NotificationBehavior } from './NotificationsHandlerModule';

type Notification = any;
export interface NotificationDelegate {
  handleNotification: (notification: Notification) => Promise<NotificationBehavior>;
  handleSuccess?: (notificationId: string) => void;
  handleError?: (error: Error) => void;
}

type HandleNotificationEvent = {
  id: string;
  notification: Notification;
};

type HandleNotificationTimeoutEvent = {
  id: string;
};

// Web uses SyntheticEventEmitter
const notificationEmitter = new EventEmitter(NotificationsHandlerModule);

const handleNotificationEventName = 'onHandleNotification';
const handleNotificationTimeoutEventName = 'onHandleNotificationTimeout';

let handleSubscription: Subscription | null = null;
let handleTimeoutSubscription: Subscription | null = null;

export function setNotificationDelegate(delegate: NotificationDelegate): void {
  if (handleSubscription) {
    handleSubscription.remove();
    handleSubscription = null;
  }
  if (handleTimeoutSubscription) {
    handleTimeoutSubscription.remove();
    handleTimeoutSubscription = null;
  }

  handleSubscription = notificationEmitter.addListener<HandleNotificationEvent>(
    handleNotificationEventName,
    async ({ id, notification }) => {
      try {
        const requestedBehavior = await delegate.handleNotification(notification);
        await NotificationsHandlerModule.handleNotificationAsync(id, requestedBehavior);
        delegate.handleSuccess?.(id);
      } catch (error) {
        delegate.handleError?.(error);
      }
    }
  );

  handleTimeoutSubscription = notificationEmitter.addListener<HandleNotificationTimeoutEvent>(
    handleNotificationTimeoutEventName,
    ({ id }) =>
      delegate.handleError?.(
        new CodedError('ERR_NOTIFICATION_TIMEOUT', `Notification handling timed out for ID ${id}.`)
      )
  );
}
