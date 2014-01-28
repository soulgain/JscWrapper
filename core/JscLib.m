//
//  JscLib.c
//  JscWrapper
//
//  Created by ikamobile on 1/27/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "JscLib.h"


void init_libs(JSContextRef context)
{
    size_t i = 0;
    
    while (1) {
        JscLib_Reg reg = Jsc_libs[i];
        if (!reg.function) {
            break;
        }
        
        JSStringRef jss = JSStringCreateWithUTF8CString(reg.name);
        reg.function(context, jss);
        i++;
    }
}
