package expo.modules.notifications.notifications;

import android.content.Context;

import com.google.firebase.messaging.RemoteMessage;

import org.unimodules.core.ExportedModule;
import org.unimodules.core.ModuleRegistry;
import org.unimodules.core.Promise;
import org.unimodules.core.arguments.ReadableArguments;
import org.unimodules.core.interfaces.ExpoMethod;
import org.unimodules.core.interfaces.services.EventEmitter;

import java.util.HashMap;
import java.util.Map;

import expo.modules.notifications.notifications.interfaces.NotificationListener;
import expo.modules.notifications.notifications.interfaces.NotificationManager;

public class NotificationsHandler extends ExportedModule implements NotificationListener {
  private final static String EXPORTED_NAME = "ExpoNotificationsHandlerModule";

  private NotificationManager mNotificationManager;
  private EventEmitter mEventEmitter;

  private Map<String, SingleNotificationHandlerTask> mTasksMap = new HashMap<>();

  public NotificationsHandler(Context context) {
    super(context);
  }

  @Override
  public String getName() {
    return EXPORTED_NAME;
  }

  @Override
  public void onCreate(ModuleRegistry moduleRegistry) {
    mEventEmitter = moduleRegistry.getModule(EventEmitter.class);

    // Register the module as a listener in NotificationManager singleton module.
    // Deregistration happens in onDestroy callback.
    mNotificationManager = moduleRegistry.getSingletonModule("NotificationManager", NotificationManager.class);
    mNotificationManager.addListener(this);
  }

  @Override
  public void onDestroy() {
    mNotificationManager.removeListener(this);
  }

  @ExpoMethod
  public void handleNotificationAsync(String identifier, ReadableArguments behavior, Promise promise) {
    SingleNotificationHandlerTask task = mTasksMap.get(identifier);
    if (task == null) {
      String message = String.format("Failed to handle notification %s, it has already been handled.", identifier);
      promise.reject("ERR_NOTIFICATION_HANDLED", message);
      return;
    }
    try {
      task.handleResponse(behavior);
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @Override
  public void onMessage(RemoteMessage message) {
    SingleNotificationHandlerTask task = new SingleNotificationHandlerTask(mEventEmitter, message, this);
    mTasksMap.put(task.getIdentifier(), task);
    task.start();
  }

  @Override
  public void onDeletedMessages() {
    // do nothing
  }

  void onTaskFinished(SingleNotificationHandlerTask task) {
    mTasksMap.remove(task.getIdentifier());
  }
}
