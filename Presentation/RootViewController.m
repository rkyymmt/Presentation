#import "RootViewController.h"
#import "HomeViewController.h"
#import "Common.h"
#import "FileManager.h"
#import <CoreRing/CoreRing.h>
#import "AppDelegate.h"

@interface RootViewController () <CRApplicationDelegate>
@end

@implementation RootViewController {
  CRApplication *_ringApp;
  HomeViewController *_homeViewController;
}

+ (RootViewController *)rootViewController {
  _L();
  return [(AppDelegate *)UIApplication.sharedApplication.delegate rootViewController];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.blackColor;
}

- (void)viewDidAppear:(BOOL)animated {
  _L();
  [super viewDidAppear:animated];
  if (self.presentedViewController)
    return;

  [FileManager.fileManager reload];

  _homeViewController = [[HomeViewController alloc] initWithNibName:nil bundle:nil];
  _homeViewController.view.alpha = 0.0;
  [self presentViewController:_homeViewController animated:NO completion:^{
      [UIView animateWithDuration:0.2 animations:^{
          _homeViewController.view.alpha = 1.0;
        }];
      [self startRing];
    }];
}

- (void)setActiveGestures:(BOOL)isListMode {
  _L();
  if (isListMode) {
    [_ringApp setActiveGestureIdentifiers:@[@"one", @"two", @"three", @"four", @"prev", @"next"]];
  } else {
    [_ringApp setActiveGestureIdentifiers:@[@"reload", @"list", @"prev", @"next"]];
  }
}

- (void)startRing {
  _ringApp = [[CRApplication alloc] initWithDelegate:self background:NO];

  NSDictionary *gestures = @{ @"reload" : CR_POINTS_CIRCLE,
                              @"list" : CR_POINTS_PIGTALE,
                              @"prev" : CR_POINTS_LEFT,
                              @"next" : CR_POINTS_RIGHT,
                              @"one" : CR_POINTS_ONE,
                              @"two" : CR_POINTS_TWO,
                              @"three" : CR_POINTS_THREE,
                              @"four" : CR_POINTS_FOUR };
  if (![[_ringApp installedGestureIdentifiers] count]) {
    NSError *error;
    if (![_ringApp installGestures:gestures error:&error]) {
      _L(@"%@", error);
      return;
    }
  }
  [self setActiveGestures:NO];
  [_ringApp start];
}

- (void)endRing {
  _ringApp = nil;
}

#pragma mark - CRApplicationDelegate

- (void)deviceDidDisconnect {
  _L();
}

- (void)deviceDidInitialize {
  _L();
}

- (void)didReceiveEvent:(CRRingEvent)event {
  _L();
}

- (void)didReceiveGesture:(NSString *)identifier {
  _L(@"%@", identifier);

  dispatch_async(dispatch_get_main_queue(), ^{
      if ([@"reload" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController reload];
        return;
      }
      if ([@"list" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController list];
        return;
      }
      if ([@"prev" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController prev];
        return;
      }
      if ([@"next" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController next];
        return;
      }
      if ([@"one" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController setPageInList:0];
        return;
      }
      if ([@"two" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController setPageInList:1];
        return;
      }
      if ([@"three" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController setPageInList:2];
        return;
      }
      if ([@"four" isEqualToString:identifier]) {
        [_homeViewController.pdfViewController setPageInList:3];
        return;
      }
    });
}

- (void)didReceiveQuaternion:(CRQuaternion)quaternion {
  _L();
}

- (void)didReceivePoint:(CGPoint)point {
  _L();
}

@end
