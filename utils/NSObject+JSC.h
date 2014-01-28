//
//  NSObject+JSC.h
//  JscWrapper
//
//  Created by ikamobile on 1/28/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JavaScriptCore.h"


@interface NSObject (JSC)

- (JSValueRef)jsvalueInContext:(JSContextRef)context;

@end
