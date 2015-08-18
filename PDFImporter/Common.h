//
//  Common.h
//  Presentation
//
//  Created by Takeshi Shoji on 2015/08/18.
//  Copyright (c) 2015年 Logbar Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#if DEBUG
#define _L(message, ...) NSLog((@"%04d:%s " message), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define _L(message, ...) (void)0
#endif

@interface Common : NSObject

@end
