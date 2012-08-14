//
//  NSURL_ComponentsExtensions.m
//  //  TouchFoundation
//
//  Created by j Wight on 8/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import "NSURL_ComponentsExtensions.h"

@implementation NSURL (NSURL_ComponentsExtensions)

+ (NSURL *)URLWithScheme:(NSString *)inScheme resourceSpecifier:(NSString *)inResourceSpecifier
    {
    NSString *theURLString = [NSString stringWithFormat:@"%@:%@", inScheme, inResourceSpecifier];
    NSURL *theURL = [NSURL URLWithString:theURLString];
    return(theURL);
    }

+ (NSURL *)URLWithComponents:(NSDictionary *)inComponents
    {
    NSString *theScheme = [inComponents objectForKey:@"scheme"];
    NSString *theResourceSpecifier = [self resourceSpecifierWithComponents:inComponents];
    NSURL *theURL = [self URLWithScheme:theScheme resourceSpecifier:theResourceSpecifier];
    return(theURL);
    }

+ (NSString *)resourceSpecifierWithComponents:(NSDictionary *)inComponents
    {
    // TODO:what about relative URLs?
    
    NSMutableString *theResourceSpecifier = [NSMutableString stringWithString:@"//"];

    // http://www.ietf.org/rfc/rfc1808.txt

    // //(<username>:<password>@)<host>(:<port>)(/<path>)(;<parameterString>)(?<query>)(#<fragment>)
    
    id theComponent = NULL;

    if ((theComponent = [inComponents objectForKey:@"username"]) != NULL)
        {
        [theResourceSpecifier appendString:theComponent];

        if ((theComponent = [inComponents objectForKey:@"password"]) != NULL)
            {
            [theResourceSpecifier appendFormat:@":%@", theComponent];
            }

        [theResourceSpecifier appendString:@"@"];
        }

    if ((theComponent = [inComponents objectForKey:@"host"]) != NULL)
        {
        [theResourceSpecifier appendString:theComponent];
        }

    if ((theComponent = [inComponents objectForKey:@"port"]) != NULL)
        {
        [theResourceSpecifier appendFormat:@":%d", [theComponent shortValue]];
        }

    if ((theComponent = [inComponents objectForKey:@"path"]) != NULL)
        {
        [theResourceSpecifier appendString:theComponent];
        }

    if ((theComponent = [inComponents objectForKey:@"parameterString"]) != NULL)
        {
        [theResourceSpecifier appendFormat:@";%@", theComponent];
        }

    if ((theComponent = [inComponents objectForKey:@"query"]) != NULL)
        {
        [theResourceSpecifier appendFormat:@"?%@", theComponent];
        }

    if ((theComponent = [inComponents objectForKey:@"fragment"]) != NULL)
        {
        [theResourceSpecifier appendFormat:@"#%@", theComponent];
        }
        
    return(theResourceSpecifier);
    }

- (NSDictionary *)components
    {
    NSMutableDictionary *theComponents = [NSMutableDictionary dictionary];
    
    NSArray *theKeys = [NSArray arrayWithObjects:@"scheme", @"host", @"port", @"user", @"password", @"path", @"fragment", @"parameterString", @"query", NULL];
    
    for (NSString *theKey in theKeys)
        {
        id theValue = [self valueForKey:theKey];
        if (theValue)
            {
            [theComponents setObject:theValue forKey:theKey];
            }
        }
    
    return(theComponents);
    }

- (NSURL *)URLByReplacingQuery:(NSString *)inQuery
    {
    NSMutableDictionary *theComponents = [[self components] mutableCopy];
    [theComponents setObject:inQuery forKey:@"query"];    
    NSURL *theURL = [NSURL URLWithComponents:theComponents];
    return(theURL);
    }


@end
