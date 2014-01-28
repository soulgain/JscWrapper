//
//  JscVM.h
//  JscWrapper
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JscCommon.h"
#import "JavaScriptCore.h"
#import "NSString+JSC.h"
#import "JscHelper.h"


@interface JscVM : NSObject

@property (nonatomic) JSGlobalContextRef context;
@property (nonatomic) JSObjectRef globalObject;
@property (nonatomic, strong) void(^exceptionHandler)(JSContextRef context, JSValueRef e);

- (JSValueRef)evalJSFile:(NSString *)filePath;
- (JSValueRef)evalJSString:(NSString *)script;

@end
