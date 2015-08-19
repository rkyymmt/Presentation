#import "FileManager.h"
#import "AppDelegate.h"
#import "Common.h"

@implementation FileManager

+ (FileManager *)fileManager {
  _L();
  return [(AppDelegate *)UIApplication.sharedApplication.delegate fileManager];
}

#pragma mark - Index

- (NSString *)itemListsPath {
  NSURL *url = [self.library URLByAppendingPathComponent:@"itemLists"];
  return url.path;
}

- (NSArray *)itemLists {
  NSArray *itemLists = [NSArray arrayWithContentsOfFile:self.itemListsPath];
  if (!itemLists)
    itemLists = NSArray.new;
  _L();
  return itemLists;
}

- (void)saveItemLists:(NSArray *)itemLists {
  _L();
  [itemLists writeToFile:self.itemListsPath atomically:NO];
}

- (BOOL)itemExists:(NSString *)item inItemLists:(NSArray *)itemLists {
  _L();
  for (NSArray *itemList in itemLists) {
    for (NSString *it in itemList) {
      if ([it isEqualToString:item])
        return YES;
    }
  }
  return NO;
}

- (NSArray *)addItem:(NSString *)item toItemLists:(NSArray *)itemLists {
  _L();
  int index = 0;
  for (NSArray *itemList in itemLists) {
    if (itemList.count < 6)
      break;
    index++;
  }
  NSMutableArray *result = [NSMutableArray arrayWithArray:itemLists];
  if (index < itemLists.count) {
    result[index] = [result[index] arrayByAddingObject:item];
  } else {
    [result addObject:@[item]];
  }
  return result;
}

#pragma mark - Dirs

- (NSURL *)documents {
  NSArray *urls = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
  return urls.lastObject;
}

- (NSURL *)inbox {
  return [self.documents URLByAppendingPathComponent:@"Inbox"];
}

- (NSURL *)group {
  NSString *groupId = @"group.jp.logbar.ring.Presentation";
  NSURL *group = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:groupId];
  return group;
}

- (NSURL *)library {
  NSArray *urls = [NSFileManager.defaultManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
  return urls.lastObject;
}

- (NSURL *)thumbDir {
  NSURL *thumbDir = [self.library URLByAppendingPathComponent:@"thumb"];
  [self createDirIfNotExists:thumbDir];
  return thumbDir;
}

- (NSURL *)itemDir {
  NSURL *itemDir = [self.library URLByAppendingPathComponent:@"item"];
  [self createDirIfNotExists:itemDir];
  return itemDir;
}

#pragma mark - Reload

- (void)reload {
  _L();
  _L(@"%@", self.documents);

  [NSFileManager.defaultManager removeItemAtURL:self.itemDir error:nil];
  [NSFileManager.defaultManager removeItemAtURL:self.thumbDir error:nil];

  [self movePDFToDocuments:self.inbox];
  [self movePDFToDocuments:self.group];

  NSArray *pdfs = [self pdfsInDir:self.documents];
  NSMutableArray *items = NSMutableArray.new;
  for (NSURL *pdf in pdfs) {
    [items addObject:pdf.lastPathComponent];
  }
  NSArray *itemLists = self.itemLists;
  for (NSString *item in items) {
    if (![self itemExists:item inItemLists:itemLists]) {
      itemLists = [self addItem:item toItemLists:itemLists];
    }
    [self createThumbnail:item];
  }
  _L(@"%@", itemLists);
  [self saveItemLists:itemLists];
}

#pragma mark - Private

- (NSArray *)pdfsInDir:(NSURL *)dir {
  NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtURL:dir
                                                 includingPropertiesForKeys:nil
                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                 error:nil];
  NSMutableArray *pdfs = NSMutableArray.new;
  for (NSURL *file in files) {
    if (NSOrderedSame == [@"pdf" caseInsensitiveCompare:file.pathExtension])
      [pdfs addObject:file];
  }
  _L(@"%@", pdfs);
  return pdfs;
}

- (void)movePDFToDocuments:(NSURL *)dir {
  _L();
  NSArray *files = [self pdfsInDir:dir];
  if (!files || !files.count)
    return;
  for (NSURL *file in files) {
    NSError *error;
    NSURL *to = [self.documents URLByAppendingPathComponent:file.lastPathComponent];
    if (![NSFileManager.defaultManager moveItemAtURL:file toURL:to error:&error]) {
      _L(@"%@", error);
    }
  }
}

- (void)createDirIfNotExists:(NSURL *)dir {
  _L();
  if ([dir checkResourceIsReachableAndReturnError:nil])
    return;
  NSError *error;
  if (![NSFileManager.defaultManager createDirectoryAtURL:dir
                                     withIntermediateDirectories:YES
                                     attributes:nil
                                     error:&error]) {
    _L(@"%@", error);
  }
}

#pragma mark - Thumnail

- (void)createThumbnail:(NSString *)item {
  _L();
  CGFloat width = UIScreen.mainScreen.bounds.size.width / 3 * UIScreen.mainScreen.scale;

  NSURL *url = [self.documents URLByAppendingPathComponent:item];

  CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)url);
  CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
  CGRect pdfRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
  CGFloat scale = width / MAX(pdfRect.size.width, pdfRect.size.height);
  CGSize size = CGSizeMake(pdfRect.size.width * scale, pdfRect.size.height * scale);

  UIGraphicsBeginImageContext(size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextScaleCTM(context, scale, -1.0 * scale);
  CGContextTranslateCTM(context, 0.0, -1.0 * pdfRect.size.height);
  CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
  CGContextFillRect(context, CGRectMake(pdfRect.origin.x + 2,
                                        pdfRect.origin.y + 2,
                                        pdfRect.size.width - 4,
                                        pdfRect.size.height - 4));
  CGContextDrawPDFPage(context, page);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  NSURL *imageUrl = [self.thumbDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", item]];
  [UIImagePNGRepresentation(image) writeToFile:imageUrl.path atomically:YES];

  CGPDFDocumentRelease(document);
}

- (UIImage *)thumbnailForItem:(NSString *)item {
  _L();
  NSURL *url = [self.thumbDir URLByAppendingPathComponent:item];
  return [UIImage imageWithContentsOfFile:url.path];
}

#pragma mark - PDF

- (int)numberOfPages:(NSString *)item {
  NSURL *pdfUrl = [self.documents URLByAppendingPathComponent:item];
  CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)pdfUrl);
  int nPages = (int)CGPDFDocumentGetNumberOfPages(document);
  CGPDFDocumentRelease(document);
  return nPages;
}

- (NSURL *)imageURL:(NSString *)item page:(int)page {
  return [self.itemDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%03d.png", item, page]];
}

- (UIImage *)imageWithItem:(NSString *)item page:(int)page {
  _L();
  NSURL *imageUrl = [self imageURL:item page:page];
  if ([imageUrl checkResourceIsReachableAndReturnError:nil])
    return [UIImage imageWithContentsOfFile:imageUrl.path];

  CGFloat width = UIScreen.mainScreen.bounds.size.width * UIScreen.mainScreen.scale;
  NSURL *pdfUrl = [self.documents URLByAppendingPathComponent:item];
  CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)pdfUrl);
  CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, page);
  CGRect pdfRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
  CGFloat scale = width / MAX(pdfRect.size.width, pdfRect.size.height);
  CGSize size = CGSizeMake(pdfRect.size.width * scale, pdfRect.size.height * scale);

  UIGraphicsBeginImageContext(size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextScaleCTM(context, scale, -1.0 * scale);
  CGContextTranslateCTM(context, 0.0, -1.0 * pdfRect.size.height);
  CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
  CGContextFillRect(context, CGRectMake(pdfRect.origin.x + 2,
                                        pdfRect.origin.y + 2,
                                        pdfRect.size.width - 4,
                                        pdfRect.size.height - 4));
  CGContextDrawPDFPage(context, pdfPage);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  [UIImagePNGRepresentation(image) writeToFile:imageUrl.path atomically:YES];
  CGPDFDocumentRelease(document);

  return image;
}

@end
