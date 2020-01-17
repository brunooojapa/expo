package expo.modules.notifications.notifications;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.google.firebase.messaging.RemoteMessage;

import org.unimodules.core.arguments.ReadableArguments;
import org.unimodules.core.interfaces.services.EventEmitter;

import java.util.UUID;

/* package */ class SingleNotificationHandlerTask {
  private final static Handler HANDLER = new Handler(Looper.getMainLooper());

  private final static String HANDLE_NOTIFICATION_EVENT_NAME = "onHandleNotification";
  private final static String HANDLE_NOTIFICATION_TIMEOUT_EVENT_NAME = "onHandleNotificationTimeout";

  private final static int SECONDS_TO_TIMEOUT = 3;

  private EventEmitter mEventEmitter;
  private RemoteMessage mRemoteMessage;
  private NotificationsHandler mDelegate;
  private String mIdentifier;

  private Runnable mTimeoutRunnable = new Runnable() {
    @Override
    public void run() {
      SingleNotificationHandlerTask.this.handleTimeout();
    }
  };

  /* package */ SingleNotificationHandlerTask(EventEmitter eventEmitter, RemoteMessage remoteMessage, NotificationsHandler delegate) {
    mEventEmitter = eventEmitter;
    mRemoteMessage = remoteMessage;
    mDelegate = delegate;
    mIdentifier = remoteMessage.getMessageId();
    if (mIdentifier == null) {
      mIdentifier = UUID.randomUUID().toString();
    }
  }

  /* package */ String getIdentifier() {
    return mIdentifier;
  }

  /* package */ void start() {
    Bundle eventBody = new Bundle();
    eventBody.putString("id", getIdentifier());
    eventBody.putBundle("notification", RemoteMessageSerializer.toBundle(mRemoteMessage));
    mEventEmitter.emit(HANDLE_NOTIFICATION_EVENT_NAME, eventBody);

    HANDLER.postDelayed(mTimeoutRunnable, SECONDS_TO_TIMEOUT * 1000);
  }

  /* package */ void handleResponse(final ReadableArguments arguments) {
    HANDLER.post(new Runnable() {
      @Override
      public void run() {
        // here we would show the notification
        Log.d("NotificationHandlerTask", String.format("Showing notification %s with params: %s", getIdentifier(), arguments.toBundle()));
        finish();
      }
    });
  }

  private void handleTimeout() {
    Log.d("NotificationHandlerTask", String.format("Notification %s timed out", getIdentifier()));

    Bundle eventBody = new Bundle();
    eventBody.putString("id", getIdentifier());
    eventBody.putBundle("notification", RemoteMessageSerializer.toBundle(mRemoteMessage));
    mEventEmitter.emit(HANDLE_NOTIFICATION_TIMEOUT_EVENT_NAME, eventBody);

    finish();
  }

  private void finish() {
    HANDLER.removeCallbacks(mTimeoutRunnable);
    mDelegate.onTaskFinished(this);
  }
}
