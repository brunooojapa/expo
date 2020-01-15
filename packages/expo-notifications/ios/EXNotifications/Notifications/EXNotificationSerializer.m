// Copyright 2018-present 650 Industries. All rights reserved.

#import <EXNotifications/EXNotificationsModule+UNSerializer.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@implementation EXNotificationSerializer

+ (NSDictionary *)serializedNotificationResponse:(UNNotificationResponse *)response
{
  NSMutableDictionary *serializedResponse = [NSMutableDictionary dictionary];
  [serializedResponse setValue:response.actionIdentifier forKey:@"actionIdentifier"];
  [serializedResponse setValue:[self serializedNotification:response.notification] forKey:@"notification"];
  if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
    UNTextInputNotificationResponse *textInputResponse = (UNTextInputNotificationResponse *)response;
    [serializedResponse setValue:textInputResponse.userText forKey:@"userText"];
  }
  return serializedResponse;
}

+ (NSDictionary *)serializedNotification:(UNNotification *)notification
{
  NSMutableDictionary *serializedNotification = [NSMutableDictionary dictionary];
  [serializedNotification setValue:[self serializedNotificationRequest:notification.request] forKey:@"request"];
  [serializedNotification setValue:notification.date.description forKey:@"date"];
  return serializedNotification;
}

+ (NSDictionary *)serializedNotificationRequest:(UNNotificationRequest *)request
{
  NSMutableDictionary *serializedRequest = [NSMutableDictionary dictionary];
  [serializedRequest setValue:request.identifier forKey:@"identifier"];
  [serializedRequest setValue:[self serializedNotificationContent:request.content] forKey:@"content"];
  [serializedRequest setValue:[self serializedNotificationTrigger:request.trigger] forKey:@"trigger"];
  return serializedRequest;
}

+ (NSDictionary *)serializedNotificationContent:(UNNotificationContent *)content
{
  NSMutableDictionary *serializedContent = [NSMutableDictionary dictionary];
  [serializedContent setValue:content.title forKey:@"title"];
  [serializedContent setValue:content.subtitle forKey:@"subtitle"];
  [serializedContent setValue:content.body forKey:@"body"];
  [serializedContent setValue:content.badge forKey:@"badge"];
  [serializedContent setValue:content.sound.description forKey:@"sound"]; // TODO: Verify that description of UNNotificationSound is informative
  [serializedContent setValue:content.launchImageName forKey:@"launchImageName"];
  [serializedContent setValue:content.userInfo forKey:@"userInfo"];
  [serializedContent setValue:[self serializedNotificationAttachments:content.attachments] forKey:@"attachments"];

  if (@available(iOS 12.0, *)) {
    [serializedContent setValue:content.summaryArgument forKey:@"summaryArgument"];
    [serializedContent setValue:@(content.summaryArgumentCount) forKey:@"summaryArgumentCount"];
  }

  [serializedContent setValue:content.categoryIdentifier forKey:@"categoryIdentifier"];
  [serializedContent setValue:content.threadIdentifier forKey:@"threadIdentifier"];
  if (@available(iOS 13.0, *)) {
    [serializedContent setValue:content.targetContentIdentifier forKey:@"targetContentIdentifier"];
  }

  return serializedContent;
}

+ (NSArray *)serializedNotificationAttachments:(NSArray<UNNotificationAttachment *> *)attachments
{
  NSMutableArray *serializedAttachments = [NSMutableArray array];
  for (UNNotificationAttachment *attachment in attachments) {
    [serializedAttachments addObject:[self serializedNotificationAttachment:attachment]];
  }
  return serializedAttachments;
}

+ (NSDictionary *)serializedNotificationAttachment:(UNNotificationAttachment *)attachment
{
  NSMutableDictionary *serializedAttachment = [NSMutableDictionary dictionary];
  [serializedAttachment setValue:attachment.identifier forKey:@"identifier"];
  [serializedAttachment setValue:attachment.URL.absoluteString forKey:@"url"];
  [serializedAttachment setValue:attachment.type forKey:@"type"];
  return serializedAttachment;
}

+ (NSDictionary *)serializedNotificationTrigger:(UNNotificationTrigger *)trigger
{
  NSMutableDictionary *serializedTrigger = [NSMutableDictionary dictionary];
  [serializedTrigger setValue:NSStringFromClass(trigger.class) forKey:@"class"];
  [serializedTrigger setValue:@(trigger.repeats) forKey:@"repeats"];
  if ([trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [serializedTrigger setValue:@"push" forKey:@"type"];
  } else if ([trigger isKindOfClass:[UNCalendarNotificationTrigger class]]) {
    [serializedTrigger setValue:@"calendar" forKey:@"type"];
    UNCalendarNotificationTrigger *calendarTrigger = (UNCalendarNotificationTrigger *)trigger;
    [serializedTrigger setValue:[self serializedDateComponents:calendarTrigger.dateComponents] forKey:@"dateComponents"];
  } else if ([trigger isKindOfClass:[UNLocationNotificationTrigger class]]) {
    [serializedTrigger setValue:@"location" forKey:@"type"];
    UNLocationNotificationTrigger *locationTrigger = (UNLocationNotificationTrigger *)trigger;
    [serializedTrigger setValue:[self serializedRegion:locationTrigger.region] forKey:@"region"];
  } else {
    [serializedTrigger setValue:@"unknown" forKey:@"type"];
  }
  return serializedTrigger;
}

+ (NSDictionary *)serializedDateComponents:(NSDateComponents *)dateComponents
{
  NSMutableDictionary *serializedComponents = [NSMutableDictionary dictionary];
  NSArray<NSNumber *> *autoConvertedUnits = [[self calendarUnitsConversionMap] allKeys];
  for (NSNumber *calendarUnitNumber in autoConvertedUnits) {
    NSCalendarUnit calendarUnit = [calendarUnitNumber unsignedIntegerValue];
    [serializedComponents setValue:@([dateComponents valueForComponent:calendarUnit]) forKey:[self keyForCalendarUnit:calendarUnit]];
  }
  [serializedComponents setValue:dateComponents.date forKey:@"date"];
  [serializedComponents setValue:dateComponents.calendar.calendarIdentifier forKey:@"calendar"];
  [serializedComponents setValue:dateComponents.timeZone.description forKey:@"timeZone"];
  [serializedComponents setValue:dateComponents.date forKey:@"date"];
  [serializedComponents setValue:@(dateComponents.isLeapMonth) forKey:@"isLeapMonth"];
  return serializedComponents;
}

+ (NSDictionary *)calendarUnitsConversionMap
{
  static NSDictionary *keysMap = nil;
  if (!keysMap) {
    keysMap = @{
      @(NSCalendarUnitEra): @"era",
      @(NSCalendarUnitYear): @"year",
      @(NSCalendarUnitMonth): @"month",
      @(NSCalendarUnitDay): @"day",
      @(NSCalendarUnitHour): @"hour",
      @(NSCalendarUnitMinute): @"minute",
      @(NSCalendarUnitSecond): @"second",
      @(NSCalendarUnitWeekday): @"weekday",
      @(NSCalendarUnitWeekdayOrdinal): @"weekdayOrdinal",
      @(NSCalendarUnitQuarter): @"quarter",
      @(NSCalendarUnitWeekOfMonth): @"weekOfMonth",
      @(NSCalendarUnitWeekOfYear): @"weekOfYear",
      @(NSCalendarUnitYearForWeekOfYear): @"yearForWeekOfYear",
      @(NSCalendarUnitNanosecond): @"nanosecond"
      // NSCalendarUnitCalendar and NSCalendarUnitTimeZone
      // should be handled separately
    };
  }
  return keysMap;
}

+ (NSString *)keyForCalendarUnit:(NSCalendarUnit)calendarUnit
{
  return [self calendarUnitsConversionMap][@(calendarUnit)];
}

+ (NSDictionary *)serializedRegion:(CLRegion *)region
{
  NSMutableDictionary *serializedRegion = [NSMutableDictionary dictionary];
  [serializedRegion setValue:region.identifier forKey:@"identifier"];
  [serializedRegion setValue:@(region.notifyOnEntry) forKey:@"notifyOnEntry"];
  [serializedRegion setValue:@(region.notifyOnExit) forKey:@"notifyOnExit"];
  if ([region isKindOfClass:[CLCircularRegion class]]) {
    CLCircularRegion *circularRegion = (CLCircularRegion *)region;
    NSDictionary *serializedCenter = @{
      @"latitude": @(circularRegion.center.latitude),
      @"longitude": @(circularRegion.center.longitude)
    };
    [serializedRegion setValue:serializedCenter forKey:@"center"];
    [serializedRegion setValue:@(circularRegion.radius) forKey:@"radius"];
  }
  return serializedRegion;
}

@end

NS_ASSUME_NONNULL_END
