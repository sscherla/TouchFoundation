//
//  CLazyCacheTestCase.m
//  TouchCode
//
//  Created by Jonathan Wight on 6/25/09.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CLazyCacheTestCase.h"

#import "CLazyCache.h"

@implementation CLazyCacheTestCase

- (void)testCache1
{
CLazyCache *theCache = [[[CLazyCache alloc] initWithCapacity:2] autorelease];
STAssertEquals(theCache.capacity, 2U, @"Capacity doesn't match");
STAssertEquals(theCache.count, 0U, @"Count not 0");
[theCache cacheObject:@"A" forKey:@"1"];
STAssertEquals(theCache.count, 1U, @"Count not 1");
[theCache cacheObject:@"B" forKey:@"2"];
STAssertEquals(theCache.count, 2U, @"Count not 2");
[theCache cacheObject:@"C" forKey:@"3"];
STAssertEquals(theCache.count, 2U, @"Count not 2");

STAssertEqualObjects([theCache cachedObjectForKey:@"3"], @"C", @"Mismatch");
STAssertEqualObjects([theCache cachedObjectForKey:@"2"], @"B", @"Mismatch");
STAssertEqualObjects([theCache cachedObjectForKey:@"1"], NULL, @"Mismatch");
}

@end
