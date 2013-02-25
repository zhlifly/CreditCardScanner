//
//  CreditCardScannerNumberViewController.h
//  CreditCardScanner
//
//  Created by zhlifly on 13-2-24.
//  Copyright (c) 2013年 zhlifly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface CreditCardScannerNumberViewController : UIViewController<CvVideoCameraDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *previewImageView;
@property (retain, nonatomic) IBOutlet UIImageView *debugImageView;
- (IBAction)test:(id)sender;
@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end
