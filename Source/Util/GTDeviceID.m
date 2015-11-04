//
//  GTDeviceID.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/6.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTDeviceID.h"

@interface GTDeviceID ()

@property (nonatomic, strong) NSString *uidPretty;
@property (nonatomic, strong, readonly) NSString *uidKey;
@property (nonatomic, strong, readonly) NSString *uid;

@end

@implementation GTDeviceID

@synthesize uid = _uid;

#pragma mark - Public methods

+ (NSString *)uid {
    return [[[GTDeviceID alloc] initWithKey:@"com.getui.log.deviceid"] prettyUid];
}

#pragma mark - Instance methods

- (id)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        _uidKey = key;
        _uid = nil;
    }
    return self;
}

- (NSString *)prettyUid {
    if (!_uidPretty) {
        NSString *temp = [self uid];
        _uidPretty = [[temp stringByReplacingOccurrencesOfString:@"-"
                                                      withString:@""] lowercaseString];
    }
    return _uidPretty;
}

/*! Returns the Device UID.
 The UID is obtained in a chain of fallbacks:
 - Keychain
 - NSUserDefaults
 - Apple IFV (Identifier for Vendor)
 - Generate a random UUID if everything else is unavailable
 At last, the UID is persisted if needed to.
 */
- (NSString *)uid {
    if (!_uid)
        _uid = [[self class] valueForKeychainKey:_uidKey service:_uidKey];
    if (!_uid)
        _uid = [[self class] valueForUserDefaultsKey:_uidKey];
    if (!_uid)
        _uid = [[self class] appleIFV];
    if (!_uid)
        _uid = [[self class] randomUUID];
    [self save];
    return _uid;
}

/*! Persist UID to NSUserDefaults and Keychain, if not yet saved
 */
- (void)save {
    if (![GTDeviceID valueForUserDefaultsKey:_uidKey]) {
        [GTDeviceID setValue:_uid forUserDefaultsKey:_uidKey];
    }
    if (![GTDeviceID valueForKeychainKey:_uidKey service:_uidKey]) {
        [GTDeviceID setValue:_uid forKeychainKey:_uidKey inService:_uidKey];
    }
}

#pragma mark - Keychain methods

/*! Create as generic NSDictionary to be used to query and update Keychain items.
 *  param1
 *  param2
 */
+ (NSMutableDictionary *)keychainItemForKey:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id) kSecClass] = (__bridge id) kSecClassGenericPassword;
    keychainItem[(__bridge id) kSecAttrAccessible] = (__bridge id) kSecAttrAccessibleAlways;
    keychainItem[(__bridge id) kSecAttrAccount] = key;
    keychainItem[(__bridge id) kSecAttrService] = service;
    return keychainItem;
}

/*! Sets
 *  param1
 *  param2
 */
+ (OSStatus)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service];
    keychainItem[(__bridge id) kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
    return SecItemAdd((__bridge CFDictionaryRef) keychainItem, NULL);
}

+ (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service {
    OSStatus status;
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service];
    keychainItem[(__bridge id) kSecReturnData] = (__bridge id) kCFBooleanTrue;
    keychainItem[(__bridge id) kSecReturnAttributes] = (__bridge id) kCFBooleanTrue;
    CFDictionaryRef result = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef) keychainItem, (CFTypeRef *) &result);
    if (status != noErr) {
        return nil;
    }
    NSDictionary *resultDict = (__bridge_transfer NSDictionary *) result;
    NSData *data = resultDict[(__bridge id) kSecValueData];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - NSUserDefaults methods

+ (BOOL)setValue:(NSString *)value forUserDefaultsKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)valueForUserDefaultsKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - UID Generation methods

+ (NSString *)appleIFA {
    NSString *ifa = nil;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) { // a dynamic way of checking if AdSupport.framework is available
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*) (id, SEL)) [ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *advertisingIdentifier = ((NSUUID * (*) (id, SEL)) [sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        ifa = [advertisingIdentifier UUIDString];
    }
    return ifa;
}

+ (NSString *)appleIFV {
    if (NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return nil;
}

+ (NSString *)randomUUID {
    if (NSClassFromString(@"NSUUID")) {
        return [[NSUUID UUID] UUIDString];
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [((__bridge NSString *) cfuuid) copy];
    CFRelease(cfuuid);
    return uuid;
}

@end
