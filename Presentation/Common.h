#import <Foundation/Foundation.h>

#if DEBUG
#define _L(message, ...) NSLog((@"%04d:%s " message), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define _L(message, ...) (void)0
#endif

#if DEBUG
#define APP_SERVER @"http://ec2-54-201-205-54.us-west-2.compute.amazonaws.com"
#else
#define APP_SERVER @"https://app.logbar.jp"
#endif

@interface Common : NSObject
@end
