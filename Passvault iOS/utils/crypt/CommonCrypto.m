//
//  ObjectiveCCommonCrypto.m
//  TestAESSwift
//
//  Created by Erik Manor on 8/21/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "CommonCrypto.h"

@implementation CommonCrypto : NSObject

- (NSData *)encryptData:(NSString*)key iv:(NSString *)iv plainText:(NSString *)plainText {
    
    char *keyPtr = malloc(kCCKeySizeAES256+1 * sizeof(char));
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    bzero(keyPtr, sizeof(keyPtr));
    memcpy(keyPtr, keyData.bytes, keyData.length);
    
    char *ivPtr = malloc(kCCKeySizeAES128+1 * sizeof(char));
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    bzero(ivPtr, sizeof(ivPtr));
    memcpy(ivPtr, ivData.bytes, ivData.length);
    
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector */,
                                          [data bytes], [data length], /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    free(keyPtr);
    free(ivPtr);
    
    if(cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}


- (NSData *)decryptData:(NSString*)key iv:(NSString *)iv cipherText:(NSString *)cipherText {
    NSData *toReturn;
    char *keyPtr = malloc(kCCKeySizeAES256+1 * sizeof(char));
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    bzero(keyPtr, sizeof(keyPtr));
    memcpy(keyPtr, keyData.bytes, keyData.length);
    
    char *ivPtr = malloc(kCCKeySizeAES128+1 * sizeof(char));
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    bzero(ivPtr, sizeof(ivPtr));
    memcpy(ivPtr, ivData.bytes, ivData.length);
    
    //NSData *data = [cipherText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector */,
                                          [data bytes], [data length], /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    free(keyPtr);
    free(ivPtr);
    
    if(cryptStatus == kCCSuccess) {
        toReturn = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        //return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    //free(buffer);
    return toReturn;
}



- (NSString *)encryptString:(NSString*)key iv:(NSString *)iv plainText:(NSString *)plainText {
    NSData *data = [self encryptData:key iv:iv plainText:plainText];
    
    if ((data) != nil) {
        return [data base64EncodedStringWithOptions:0];
    }
    
    return nil;
}



- (NSString *)decryptString:(NSString*)key iv:(NSString *)iv cipherText:(NSString *)cipherText {
    NSData *data = [self decryptData:key iv:iv cipherText:cipherText];
    
    if (data != nil) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}


- (NSString *)encryptString:(NSString*)key plainText:(NSString *)plainText {
    NSData *data = [self encryptData:key iv:@"" plainText:plainText];
    
    if ((data) != nil) {
        return [data base64EncodedStringWithOptions:0];
    }
    
    return nil;
}



- (NSString *)decryptString:(NSString*)key cipherText:(NSString *)cipherText {
    NSData *data = [self decryptData:key iv:@"" cipherText:cipherText];
    
    if (data != nil) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}


@end
