#import "AppDelegate.h"
#import "Common.h"

@implementation AppDelegate {
  FileManager *_fileManager;
  UIWindow *_window;
  RootViewController *_rootViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _L();
  _fileManager = FileManager.new;
  _rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];

  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _window.backgroundColor = UIColor.blackColor;
  _window.rootViewController = _rootViewController;
  [_window addSubview:_rootViewController.view];
  [_window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  _L();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  _L();
}

- (BOOL)application:(UIApplication *)application
        openURL:(NSURL *)url
        sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
  _L();
  return YES;
}

#pragma mark - Public

- (FileManager *)fileManager {
  return _fileManager;
}

- (RootViewController *)rootViewController {
  return _rootViewController;
}

@end
