//
//  MMKeychain.m
//  Created by Mike Mayo on 7/9/13.
//

#import "MMKeychain.h"

@implementation MMKeychain

+ (NSString *)appName {
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
	// Attempt to find a name for this application
	NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (!appName) {
		appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
	}
    return appName;
}

+ (BOOL)deleteStringForKey:(NSString *)key {
    if (key == nil) {
        return NO;
    }
    
    key = [NSString stringWithFormat:@"%@ - %@", [MMKeychain appName], key];
    
	// First check if it already exists, by creating a search dictionary and requesting that
    // nothing be returned, and performing the search anyway.
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
    
	[existsQueryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
    
	OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, NULL);
	if (res == errSecItemNotFound) {
        return YES;
	} else if (res == errSecSuccess) {
        res = SecItemDelete((__bridge CFDictionaryRef)existsQueryDictionary);
		NSAssert1(res == errSecSuccess, @"SecItemDelete returned %ld!", res);
	} else {
		NSAssert1(NO, @"Received %ld from SecItemCopyMatching!", res);
	}
    
    return YES;
}

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key {
	if (string == nil || key == nil) {
		return NO;
	}
    
    key = [NSString stringWithFormat:@"%@ - %@", [MMKeychain appName], key];
    
	// First check if it already exists, by creating a search dictionary and requesting that
    // nothing be returned, and performing the search anyway.
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	[existsQueryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
    
	OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, NULL);
	if (res == errSecItemNotFound) {
		if (string != nil) {
			NSMutableDictionary *addDict = existsQueryDictionary;
			[addDict setObject:data forKey:(__bridge id)kSecValueData];
            
			res = SecItemAdd((__bridge CFDictionaryRef)addDict, NULL);
			NSAssert1(res == errSecSuccess, @"Recieved %ld from SecItemAdd!", res);
		}
	} else if (res == errSecSuccess) {
		// Modify an existing one
		// Actually pull it now of the keychain at this point.
		NSDictionary *attributeDict = @{(__bridge id)kSecValueData: data};
        
		res = SecItemUpdate((__bridge CFDictionaryRef)existsQueryDictionary, (__bridge CFDictionaryRef)attributeDict);
		NSAssert1(res == errSecSuccess, @"SecItemUpdated returned %ld!", res);
		
	} else {
		NSAssert1(NO, @"Received %ld from SecItemCopyMatching!", res);
	}
	
	return YES;
}

+ (NSString *)stringForKey:(NSString *)key {
    
    key = [NSString stringWithFormat:@"%@ - %@", [MMKeychain appName], key];
    
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	[existsQueryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
	
	// We want the data back!
	NSData *data = nil;
    CFDataRef typeRef = nil;
	
	[existsQueryDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
    //	OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, (CFTypeRef *)&data);
	OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, (CFTypeRef *)&typeRef);
	if (res == errSecSuccess) {
        
        data = (__bridge NSData *)typeRef;
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		return string;
	} else {
		NSAssert1(res == errSecItemNotFound, @"SecItemCopyMatching returned %ld!", res);
	}
	
	return nil;
}

@end
