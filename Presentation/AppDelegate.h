#import <UIKit/UIKit.h>
#import "FileManager.h"
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
- (FileManager *)fileManager;
- (RootViewController *)rootViewController;
@end
