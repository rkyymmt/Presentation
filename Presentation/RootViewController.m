#import "RootViewController.h"
#import "HomeViewController.h"
#import "Common.h"
#import "FileManager.h"
#import <CoreRing/CoreRing.h>

@interface RootViewController () <CRApplicationDelegate>
@end

@implementation RootViewController {
  CRApplication *_ringApp;
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

  HomeViewController *vc = [[HomeViewController alloc] initWithNibName:nil bundle:nil];
  vc.view.alpha = 0.0;
  [self presentViewController:vc animated:NO completion:^{
      [UIView animateWithDuration:0.2 animations:^{
          vc.view.alpha = 1.0;
        }];
    }];
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
  [_ringApp setActiveGestureIdentifiers:gestures.allKeys];
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
        return;
      }

      if ([@"list" isEqualToString:identifier]) {
        return;
      }

      if ([@"left" isEqualToString:identifier]) {
        return;
      }

      if ([@"right" isEqualToString:identifier]) {
        return;
      }

      if ([@"one" isEqualToString:identifier]) {
        return;
      }

      if ([@"two" isEqualToString:identifier]) {
        return;
      }
      if ([@"three" isEqualToString:identifier]) {
        return;
      }

      if ([@"four" isEqualToString:identifier]) {
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
