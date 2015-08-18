#import <Foundation/Foundation.h>

#if DEBUG
#define _L(message, ...) NSLog((@"%04d:%s " message), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define _L(message, ...) (void)0
#endif

@interface Common : NSObject

@end
