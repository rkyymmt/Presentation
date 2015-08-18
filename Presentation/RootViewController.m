#import "RootViewController.h"
#import "HomeViewController.h"
#import "Common.h"
#import "FileManager.h"

@implementation RootViewController

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

@end
