#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController
+ (RootViewController *)rootViewController;
- (void)setActiveGestures:(BOOL)isListMode;
@end
