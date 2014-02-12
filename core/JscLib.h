//
//  JscLib.h
//  JscWrapper
//
//  Created by ikamobile on 1/27/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "JavaScriptCore.h"


#define JSC_DOMLIB "dom"
void init_dom(JSContextRef context, JSStringRef name);

#define JSC_HTTPLIB "http"
void init_http(JSContextRef context, JSStringRef name);

#define JSC_CONSOLE "console"
void init_console(JSContextRef context, JSStringRef name);


typedef void (*init_function)(JSContextRef context, JSStringRef name);

typedef struct {
    const char *name;
    init_function function;
}JscLib_Reg;


static const JscLib_Reg Jsc_libs[] = {
    {JSC_DOMLIB, init_dom},
    {JSC_HTTPLIB, init_http},
    {JSC_CONSOLE, init_console},
    {NULL, NULL}
};


void init_libs(JSContextRef context);
