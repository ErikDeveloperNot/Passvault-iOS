//
//  ObjectiveCCommonCrypto.h
//  TestAESSwift
//
//  Created by User One on 8/21/17.
//  Copyright © 2017 User One. All rights reserved.
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

