#import "HomeViewController.h"
#import "Common.h"
#import "HomeView.h"
#import "FileManager.h"

@interface HomeViewController () <HomeViewDelegate>
@end

@implementation HomeViewController {
  HomeView *_homeView;
  UIView *_headerView;
  UIActivityIndicatorView *_indicator;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];

  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _indicator.frame = self.view.bounds;
  [self.view addSubview:_indicator];

  _headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0,
                                                         self.view.bounds.size.width,
                                                         self.view.bounds.size.height * 0.15)];
  [self.view addSubview:_headerView];

  UIImageView *headerLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(_headerView.bounds.size.width * 0.03,
                                                                              0,
                                                                              _headerView.bounds.size.width / 3,
                                                                              _headerView.bounds.size.height)];
  headerLogoView.image = [UIImage imageNamed:@"home_header_logo"];
  headerLogoView.contentMode = UIViewContentModeScaleAspectFit;
  [_headerView addSubview:headerLogoView];

  UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
  reloadButton.frame = CGRectMake(_headerView.bounds.size.width - 128,
                                  (_headerView.bounds.size.height - 44) / 2,
                                  44,
                                  44);
  [reloadButton setImage:[UIImage imageNamed:@"home_reload"] forState:UIControlStateNormal];
  [reloadButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
  [_headerView addSubview:reloadButton];

  UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
  helpButton.frame = CGRectMake(_headerView.bounds.size.width - 84,
                                (_headerView.bounds.size.height - 44) / 2,
                                44,
                                44);
  [helpButton setImage:[UIImage imageNamed:@"home_help"] forState:UIControlStateNormal];
  [helpButton addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
  [_headerView addSubview:helpButton];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!_homeView)
    [self reload];
}

- (void)reload {
  _L();
  [_homeView removeFromSuperview];
  _homeView = nil;
  [_indicator startAnimating];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [FileManager.fileManager reload];
      dispatch_async(dispatch_get_main_queue(), ^{
          CGRect homeViewFrame = CGRectMake(0,
                                            self.view.bounds.size.height * 0.15,
                                            self.view.bounds.size.width,
                                            self.view.bounds.size.height * 0.8);
          _homeView.alpha = 1.0;
          _homeView = [[HomeView alloc] initWithFrame:homeViewFrame delegate:self];
          [self.view addSubview:_homeView];
          [_indicator stopAnimating];
        });
    });
}

- (void)help {
  _L();
  NSString *urlString = [NSString stringWithFormat:@"%@/public/ios/ring/presentation/help.html", APP_SERVER];
  [UIApplication.sharedApplication openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - HomeViewDelegate

- (void)itemTapped:(NSString *)item {
  _L();
  PDFViewController *vc = [[PDFViewController alloc] initWithItem:item];
  [self presentViewController:vc animated:YES completion:nil];
}

- (PDFViewController *)pdfViewController {
  UIViewController *vc = self.presentedViewController;
  if (vc && [vc isKindOfClass:PDFViewController.class]) {
    return (PDFViewController *)vc;
  }
  return nil;
}

@end
