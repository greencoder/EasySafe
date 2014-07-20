//
//  MMKeychain.h
//  Created by Mike Mayo on 7/9/13.
//

/**
 This is a convenience class for securely persisting and retrieving
 strings from the system keychain.
 */
@interface MMKeychain : NSObject

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)deleteStringForKey:(NSString *)key;

@end
