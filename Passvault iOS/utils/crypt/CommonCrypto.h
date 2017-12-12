//
//  ObjectiveCCommonCrypto.h
//  TestAESSwift
//
//  Created by Erik Manor on 8/21/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonCrypto : NSObject

- (NSData *)encryptData:(NSString*)key iv:(NSString *)iv plainText:(NSString *)plainText;
- (NSData *)decryptData:(NSString*)key iv:(NSString *)iv cipherText:(NSString *)cipherText;

- (NSString *)encryptString:(NSString*)key iv:(NSString *)iv plainText:(NSString *)plainText;
- (NSString *)decryptString:(NSString*)key iv:(NSString *)iv cipherText:(NSString *)cipherText;

- (NSString *)encryptString:(NSString*)key plainText:(NSString *)plainText;
- (NSString *)decryptString:(NSString*)key cipherText:(NSString *)cipherText;

@end

