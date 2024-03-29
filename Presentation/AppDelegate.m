#import "AppDelegate.h"
#import "Common.h"
#import <CoreRing/CoreRing.h>

@implementation AppDelegate {
  FileManager *_fileManager;
  UIWindow *_window;
  RootViewController *_rootViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _L();
  [application setIdleTimerDisabled:YES];

  _fileManager = FileManager.new;
  _rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];

  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _window.backgroundColor = UIColor.blackColor;
  _window.rootViewController = _rootViewController;
  [_window addSubview:_rootViewController.view];
  [_window makeKeyAndVisible];
  return YES;
}

- (BOOL)application:(UIApplication *)application
        openURL:(NSURL *)url
        sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
  _L(@"%@", url);
  if ([@"pdf" isEqualToString:url.pathExtension])
    [_rootViewController openURL:url];
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
