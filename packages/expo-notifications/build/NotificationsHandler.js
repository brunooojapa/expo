import { EventEmitter, CodedError } from '@unimodules/core';
import NotificationsHandlerModule from './NotificationsHandlerModule';
// Web uses SyntheticEventEmitter
const notificationEmitter = new EventEmitter(NotificationsHandlerModule);
const handleNotificationEventName = 'onHandleNotification';
const handleNotificationTimeoutEventName = 'onHandleNotificationTimeout';
let handleSubscription = null;
let handleTimeoutSubscription = null;
export function setNotificationDelegate(delegate) {
    if (handleSubscription) {
        handleSubscription.remove();
        handleSubscription = null;
    }
    if (handleTimeoutSubscription) {
        handleTimeoutSubscription.remove();
        handleTimeoutSubscription = null;
    }
    handleSubscription = notificationEmitter.addListener(handleNotificationEventName, async ({ id, notification }) => {
        try {
            const requestedBehavior = await delegate.handleNotification(notification);
            await NotificationsHandlerModule.handleNotificationAsync(id, requestedBehavior);
            delegate.handleSuccess?.(id);
        }
        catch (error) {
            delegate.handleError?.(error);
        }
    });
    handleTimeoutSubscription = notificationEmitter.addListener(handleNotificationTimeoutEventName, ({ id }) => delegate.handleError?.(new CodedError('ERR_NOTIFICATION_TIMEOUT', `Notification handling timed out for ID ${id}.`)));
}
//# sourceMappingURL=NotificationsHandler.js.map