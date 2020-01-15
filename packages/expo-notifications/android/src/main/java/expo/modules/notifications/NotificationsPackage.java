package expo.modules.notifications;

import android.content.Context;

import org.unimodules.core.BasePackage;
import org.unimodules.core.ExportedModule;
import org.unimodules.core.interfaces.SingletonModule;

import java.util.Arrays;
import java.util.List;

import expo.modules.notifications.notifications.NotificationManager;
import expo.modules.notifications.notifications.NotificationsEmitter;
import expo.modules.notifications.tokens.PushTokenManager;
import expo.modules.notifications.tokens.PushTokenModule;

public class NotificationsPackage extends BasePackage {
  @Override
  public List<ExportedModule> createExportedModules(Context context) {
    return Arrays.asList(
        new PushTokenModule(context),
        new NotificationsEmitter(context)
    );
  }

  @Override
  public List<SingletonModule> createSingletonModules(Context context) {
    return Arrays.asList(
        new PushTokenManager(),
        new NotificationManager()
    );
  }
}
