//
//  JscHelper.h
//  JscWrapper
//
//  Created by ikamobile on 1/27/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "JavaScriptCore.h"


JSValueRef getJSValueFromNamePropertyArray(JSContextRef ctx, JSStringRef name);
void dumpJSObject(JSContextRef c, JSObjectRef obj);
void dumpJSValue(JSContextRef c, JSValueRef v);
void dumpGlobalNamePropertyArray(JSContextRef c);
