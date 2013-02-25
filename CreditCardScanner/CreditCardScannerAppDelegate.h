//
//  CreditCardScannerAppDelegate.h
//  CreditCardScanner
//
//  Created by zhlifly on 13-2-23.
//  Copyright (c) 2013年 zhlifly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreditCardScannerNumberViewController;

@interface CreditCardScannerAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CreditCardScannerNumberViewController *viewController;

@end
