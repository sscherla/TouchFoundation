//
//  CYAKeychain.m
//  TouchCode
//
//  Created by Jonathan Wight on 10/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY 2011 TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 2011 TOXICSOFTWARE.COM OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of 2011 toxicsoftware.com.

#import "CYAKeychain.h"

NSString *const kYAKeychain_ErrorDomain = @"kYAKeychain_ErrorDomain";

@interface CYAKeychain ()

- (NSDictionary *)queryDictionaryForURL:(NSURL *)inURL;

+ (NSError *)errorForStatus:(OSStatus)inStatus;

@end

#pragma mark -

@implementation CYAKeychain

@synthesize accessGroup;

+ (void)load
    {
    @autoreleasepool
        {
//        [[[self alloc] init] removeItemForAccount:@"schwa" service:@"knotes" error:NULL];
//        NSLog(@"%@", [[[self alloc] init] dataForItemWithAccount:@"schwa" service:@"knotes" error:NULL]);
//        [[[self alloc] init] setData:[@"Hello world" dataUsingEncoding:NSUTF8StringEncoding] forItemWithAccount:@"schwa" service:@"knotes" error:NULL];
//        [[[self alloc] init] setData:[@"Hello world 2" dataUsingEncoding:NSUTF8StringEncoding] forItemWithAccount:@"schwa" service:@"knotes" error:NULL];
//        NSLog(@"%@", [[[self alloc] init] dataForItemWithAccount:@"schwa" service:@"knotes" error:NULL]);

        [[[self alloc] init] setData:[@"Woo" dataUsingEncoding:NSUTF8StringEncoding] forItemWithURL:[NSURL URLWithString:@"http://schwa@toxicsoftware.com"] error:NULL];
        NSLog(@"%@", [[[self alloc] init] dataForItemWithURL:[NSURL URLWithString:@"http://schwa@toxicsoftware.com"] error:NULL]);
        }
    }

#pragma mark -

- (NSData *)dataForItemWithQuery:(NSDictionary *)inQueryDictionary error:(NSError **)outError
    {
    NSData *theData = NULL;
    
    NSMutableDictionary *theQueryDictionary = [inQueryDictionary mutableCopy];
    [theQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    if (self.accessGroup.length > 0)
        {
        [theQueryDictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
    
    CFTypeRef theResult = NULL;
    OSStatus theStatus = SecItemCopyMatching((__bridge CFDictionaryRef)theQueryDictionary, &theResult);
    if (theStatus == errSecSuccess)
        {
        theData = [(__bridge_transfer NSData *)theResult copy];
        }
    else if (theStatus != errSecItemNotFound)
        {
        if (outError)
            {
            *outError = [[self class] errorForStatus:theStatus];
            }
        }

    return(theData);
    }
    
- (BOOL)setData:(NSData *)inData forItemWithQuery:(NSDictionary *)inQueryDictionary error:(NSError **)outError
    {
    NSMutableDictionary *theQueryDictionary = [inQueryDictionary mutableCopy];
    [theQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    if (self.accessGroup.length > 0)
        {
        [theQueryDictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
    
    CFTypeRef theResult = NULL;
    OSStatus theStatus = SecItemCopyMatching((__bridge CFDictionaryRef)theQueryDictionary, &theResult);
    if (theStatus == errSecItemNotFound)
        {
        // Item doesn't exist already. Let's add it.
        [theQueryDictionary setObject:inData forKey:(__bridge id)kSecValueData];

        theStatus = SecItemAdd((__bridge CFDictionaryRef)theQueryDictionary, &theResult);
        if (theStatus != errSecSuccess)
            {
            if (outError)
                {
                *outError = [[self class] errorForStatus:theStatus];
                }
            return(NO);
            }
        }
    else if (theStatus == errSecSuccess)
        {
        // We only both to update if the data is different.
        if ([inData isEqualToData:(__bridge NSData *)theResult] == NO)
            {
            // Item exists and the old data is different to the new data, let's update it.
            [theQueryDictionary removeObjectForKey:(__bridge id)kSecReturnAttributes];
            [theQueryDictionary setObject:inData forKey:(__bridge id)kSecValueData];
            
            theStatus = SecItemUpdate((__bridge CFDictionaryRef)theQueryDictionary, (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObject:inData forKey:(__bridge id)kSecValueData]);
            if (theStatus != errSecSuccess)
                {
                if (outError)
                    {
                    *outError = [[self class] errorForStatus:theStatus];
                    }
                return(NO);
                }
            }
        }
    else
        {
        // Something unexpected has gone wrong.
        if (outError)
            {
            *outError = [[self class] errorForStatus:theStatus];
            }
        return(NO);
        }

    return(YES);
    }
    
- (BOOL)removeItemForQuery:(NSDictionary *)inQueryDictionary error:(NSError **)outError
    {
    NSMutableDictionary *theQueryDictionary = [inQueryDictionary mutableCopy];
    if (self.accessGroup.length > 0)
        {
        [theQueryDictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }

    OSStatus theStatus = SecItemDelete((__bridge CFDictionaryRef)theQueryDictionary);
    if (theStatus != errSecSuccess)
        {
        if (outError)
            {
            *outError = [[self class] errorForStatus:theStatus];
            }
        return(NO);
        }

    return(YES);
    }

#pragma mark -

- (NSData *)dataForItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError
    {
    NSAssert(inAccount.length > 0, @"No account");
    NSAssert(inService.length > 0, @"No service");
    
    NSDictionary *theQueryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
        inAccount, (__bridge id)kSecAttrAccount,
        inService, (__bridge id)kSecAttrService,
        NULL];

    NSData *theData = [self dataForItemWithQuery:theQueryDictionary error:outError];
    return(theData);
    }

- (BOOL)setData:(NSData *)inData forItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError
    {
    NSMutableDictionary *theQueryDictionary = [NSMutableDictionary dictionary];
    [theQueryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [theQueryDictionary setObject:inAccount forKey:(__bridge id)kSecAttrAccount];
    [theQueryDictionary setObject:inService forKey:(__bridge id)kSecAttrService];

    BOOL theResult = [self setData:inData forItemWithQuery:theQueryDictionary error:outError];
    return(theResult);
    }

- (BOOL)removeItemForAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError;
    {
    NSMutableDictionary *theQueryDictionary = [NSMutableDictionary dictionary];
    [theQueryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [theQueryDictionary setObject:inAccount forKey:(__bridge id)kSecAttrAccount];
    [theQueryDictionary setObject:inService forKey:(__bridge id)kSecAttrService];

    BOOL theResult = [self removeItemForQuery:theQueryDictionary error:outError];
    return(theResult);
    }

#pragma mark -

- (NSData *)dataForItemWithURL:(NSURL *)inURL error:(NSError **)outError
    {
    NSDictionary *theQueryDictionary = [self queryDictionaryForURL:inURL];
    NSData *theData = [self dataForItemWithQuery:theQueryDictionary error:outError];
    return(theData);
    }

- (BOOL)setData:(NSData *)inData forItemWithURL:(NSURL *)inURL error:(NSError **)outError
    {
    NSDictionary *theQueryDictionary = [self queryDictionaryForURL:inURL];
    BOOL theResult = [self setData:inData forItemWithQuery:theQueryDictionary error:outError];
    return(theResult);
    }

- (BOOL)removeItemForURL:(NSURL *)inURL error:(NSError **)outError
    {
    NSDictionary *theQueryDictionary = [self queryDictionaryForURL:inURL];
    BOOL theResult = [self removeItemForQuery:theQueryDictionary error:outError];
    return(theResult);
    }

#pragma mark -
    
- (NSDictionary *)queryDictionaryForURL:(NSURL *)inURL
    {
    NSAssert(inURL != NULL, @"No URL");
    NSAssert(inURL.user.length > 0, @"No user");
    NSAssert(inURL.host.length > 0, @"No hostname");
    NSAssert(inURL.scheme.length > 0, @"No scheme");

    NSDictionary *theProtocolsForSchemes = [NSDictionary dictionaryWithObjectsAndKeys:
        (__bridge id)kSecAttrProtocolFTP, @"ftp", 
//   kSecAttrProtocolFTPAccount;
        (__bridge id)kSecAttrProtocolHTTP, @"http", 
//   kSecAttrProtocolIRC;
//   kSecAttrProtocolNNTP;
//   kSecAttrProtocolPOP3;
//   kSecAttrProtocolSMTP;
//   kSecAttrProtocolSOCKS;
//   kSecAttrProtocolIMAP;
//   kSecAttrProtocolLDAP;
//   kSecAttrProtocolAppleTalk;
//   kSecAttrProtocolAFP;
//   kSecAttrProtocolTelnet;
//   kSecAttrProtocolSSH;
//   kSecAttrProtocolFTPS;
        (__bridge id)kSecAttrProtocolHTTPS, @"https", 
//   kSecAttrProtocolHTTPProxy;
//   kSecAttrProtocolHTTPSProxy;
//   kSecAttrProtocolFTPProxy;
//   kSecAttrProtocolSMB;
//   kSecAttrProtocolRTSP;
//   kSecAttrProtocolRTSPProxy;
//   kSecAttrProtocolDAAP;
//   kSecAttrProtocolEPPC;
//   kSecAttrProtocolIPP;
//   kSecAttrProtocolNNTPS;
//   kSecAttrProtocolLDAPS;
//   kSecAttrProtocolTelnetS;
//   kSecAttrProtocolIMAPS;
//   kSecAttrProtocolIRCS;
//   kSecAttrProtocolPOP3S;
        NULL];

    id theProtocol = [theProtocolsForSchemes objectForKey:inURL.scheme];

    NSMutableDictionary *theQueryDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        (__bridge id)kSecClassInternetPassword, (__bridge id)kSecClass,
        inURL.user, (__bridge id)kSecAttrAccount,
        (__bridge id)kSecAttrAuthenticationTypeDefault, (__bridge id)kSecAttrAuthenticationType,
        inURL.host, (__bridge id)kSecAttrServer,
        theProtocol, (__bridge id)kSecAttrProtocol,
        NULL];
        
    if (inURL.port)
        {
        [theQueryDictionary setObject:inURL.port forKey:(__bridge id)kSecAttrPort];
        }
    if (inURL.path)
        {
        [theQueryDictionary setObject:inURL.path forKey:(__bridge id)kSecAttrPath];
        }

    return(theQueryDictionary);
    }

#pragma mark -

+ (NSError *)errorForStatus:(OSStatus)inStatus
    {
    NSError *theError = NULL;
    NSDictionary *theUserInfo = NULL;
    switch (inStatus)
        {
        case errSecSuccess:
            break;
        case errSecUnimplemented:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"Function or operation not implemented.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecParam:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"One or more parameters passed to a function where not valid.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecAllocate:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"Failed to allocate memory.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecNotAvailable:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"No keychain is available. You may need to restart your computer.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecDuplicateItem:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"The specified item already exists in the keychain.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecItemNotFound:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"The specified item could not be found in the keychain.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecInteractionNotAllowed:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"User interaction is not allowed.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecDecode:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"Unable to decode the provided data.", NSLocalizedDescriptionKey,
                NULL];
            break;
        case errSecAuthFailed:
            theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                @"The user name or passphrase you entered is not correct.", NSLocalizedDescriptionKey,
                NULL];
            break;
        default:
            break;
        }

    theError = [NSError errorWithDomain:kYAKeychain_ErrorDomain code:inStatus userInfo:theUserInfo];
    return(theError);
    }

@end

#pragma mark -

@implementation CYAKeychain (CYAKeychain_ConvenienceExtensions)

- (NSString *)stringForItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError
    {
    NSData *theData = [self dataForItemWithAccount:inAccount service:inService error:outError];
    NSString *theString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    return(theString);
    }
    
- (BOOL)setString:(NSString *)inString forItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError
    {
    NSData *theData = [inString dataUsingEncoding:NSUTF8StringEncoding];
    BOOL theResult = [self setData:theData forItemWithAccount:inAccount service:inService error:outError];
    return(theResult);
    }

@end
