//
//  JscValue.h
//  JscWrapper
//
//  Created by ikamobile on 1/28/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JavaScriptCore.h"


@interface JscValue : NSObject

- (JscValue *)initWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context;
+ (JscValue *)valueWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context;

@end
