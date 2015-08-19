#import "HomeViewController.h"
#import "Common.h"
#import "HomeView.h"
#import "FileManager.h"
#import "PDFViewController.h"

@interface HomeViewController () <HomeViewDelegate>
@end

@implementation HomeViewController {
  HomeView *_homeView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];

  CGFloat width = self.view.bounds.size.width;
  CGFloat height = self.view.bounds.size.height;

  CGRect homeViewFrame = CGRectMake(0,
                                    height * 0.18,
                                    width,
                                    height * 0.8);
  _homeView = [[HomeView alloc] initWithFrame:homeViewFrame delegate:self];
  [self.view addSubview:_homeView];
}

#pragma mark - HomeViewDelegate

- (void)itemTapped:(NSString *)item {
  _L();
  PDFViewController *vc = [[PDFViewController alloc] initWithItem:item];
  [self presentViewController:vc animated:YES completion:nil];
}

@end
