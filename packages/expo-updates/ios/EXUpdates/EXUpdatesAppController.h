//  Copyright © 2019 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesAppLoader.h>
#import <EXUpdates/EXUpdatesAppLoaderEmbedded.h>
#import <EXUpdates/EXUpdatesDatabase.h>
#import <EXUpdates/EXUpdatesSelectionPolicy.h>
#import <React/RCTBridge.h>

NS_ASSUME_NONNULL_BEGIN

@class EXUpdatesAppController;

@protocol EXUpdatesAppControllerDelegate <NSObject>

- (void)appController:(EXUpdatesAppController *)appController didStartWithSuccess:(BOOL)success;

@end

@interface EXUpdatesAppController : NSObject <EXUpdatesAppLoaderDelegate>

/**
 Delegate which will be notified when EXUpdates has an update ready to launch and
 `launchAssetUrl` is nonnull.
 */
@property (nonatomic, weak) id<EXUpdatesAppControllerDelegate> delegate;

/**
 The RCTBridge for which EXUpdates is providing the JS bundle and assets.
 This is optional, but required in order for `Updates.reload()` and Updates module events to work.
 */
@property (nonatomic, weak) RCTBridge *bridge;

/**
 The URL on disk to source asset for the RCTBridge.
 Will be null until the EXUpdatesAppController delegate method is called.
 This should be provided in the `sourceURLForBridge:` method of RCTBridgeDelegate.
 */
@property (nonatomic, readonly, strong) NSURL * _Nullable launchAssetUrl;
/**
 A dictionary of the locally downloaded assets for the current update. Keys are the remote URLs
 of the assets and values are local paths. This should be exported by the Updates JS module and
 can be used by `expo-asset` or a similar module to override React Native's asset resolution and
 use the locally downloaded assets.
 */
@property (nonatomic, readonly, strong) NSDictionary * _Nullable assetFilesMap;

/**
 for internal use in EXUpdates
 */
@property (nonatomic, readonly) EXUpdatesDatabase *database;
@property (nonatomic, readonly) id<EXUpdatesSelectionPolicy> selectionPolicy;
@property (nonatomic, readonly) NSURL *updatesDirectory;
@property (nonatomic, readonly, assign) BOOL isEnabled;
@property (nonatomic, readonly, assign) BOOL isEmergencyLaunch;
@property (nonatomic, readonly, strong) EXUpdatesUpdate * _Nullable launchedUpdate;

+ (instancetype)sharedInstance;

/**
 Starts the update process to launch a previously-loaded update and (if configured to do so)
 check for a new update from the server. This method should be called as early as possible in
 the application's lifecycle.

 Note that iOS may stop showing the app's splash screen in case the update is taking a while
 to load. If your splash screen setup is simple, you may want to use the
 `startAndShowLaunchScreen:` method instead.
 */
- (void)start;

/**
 Starts the update process to launch a previously-loaded update and (if configured to do so)
 check for a new update from the server. This method should be called as early as possible in
 the application's lifecycle.

 Note that iOS may stop showing the app's splash screen in case the update is taking a while
 to load. This method will attempt to find `LaunchScreen.xib` and load it into view while the
 update is loading.
 */
- (void)startAndShowLaunchScreen:(UIWindow *)window;

- (BOOL)requestRelaunch;

@end

NS_ASSUME_NONNULL_END
