//
//  TouchcodePrefix.h
//  TouchCode
//
//  Created by Jonathan Wight on 10/15/2005.
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

#ifdef __OBJC__

	#if !defined(DEBUG) || DEBUG == 0
		#define NS_BLOCK_ASSERTIONS 1
	#endif

	#if DEBUG == 1
		#define Assert_ NSAssert

		#define AssertC_ NSCAssert

		#define AssertParameter_ NSParameterAssert

		#define AssertUnimplemented_() Assert_(0, @"Method unimplemented")

		#define AssertCastOld_(CLS_, OBJ_) ({ \
			id theObject_ = (OBJ_); \
			if (theObject_ != NULL) \
				{ \
				Class theDesiredClass_ = [CLS_ class]; \
				NSAssert2([theObject_ isKindOfClass:theDesiredClass_], @"Object %@ not of class %@", theObject_, NSStringFromClass(theDesiredClass_)); \
				} \
			(CLS_ *)theObject_; \
			})

		#define AssertCast_(CLS_, OBJ_) ({ \
			id theObject_ = (OBJ_); \
			if (theObject_ != NULL) \
				{ \
				Class theDesiredClass_ = CLS_; \
				NSAssert2([theObject_ isKindOfClass:theDesiredClass_], @"Object %@ not of class %@", theObject_, NSStringFromClass(theDesiredClass_)); \
				} \
			(id)theObject_; \
			})

		#define AssertOnMainThread_() Assert_([NSThread isMainThread], @"Should be on main thread");
	#else
		#define Assert_(test, ...) ((void) 0)

		#define AssertC_(test, ...) ((void) 0)

        #define AssertParameter_(test) ((void) 0)

		#define AssertUnimplemented_() ((void) 0)

		#define AssertCastOld_(CLS_, OBJ_) ({ (CLS_ *)(OBJ_); })

		#define AssertCast_(CLS_, OBJ_) ({ (id)(OBJ_); })

		#define AssertOnMainThread_() ((void) 0)

	#endif

    #define AbortIf_(test, ...) do { \
        if ((test)) { \
            fprintf(stderr, "ABORT: %s\n", [[NSString stringWithFormat:__VA_ARGS__] UTF8String]); \
            abort(); \
            }; \
        } while(0);


#endif
