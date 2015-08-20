#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController
+ (RootViewController *)rootViewController;
- (void)setActiveGestures:(BOOL)isListMode;
- (void)openURL:(NSURL *)url;
@end
