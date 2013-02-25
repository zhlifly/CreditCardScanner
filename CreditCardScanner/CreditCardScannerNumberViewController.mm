//
//  CreditCardScannerNumberViewController.m
//  CreditCardScanner
//
//  Created by zhlifly on 13-2-24.
//  Copyright (c) 2013年 zhlifly. All rights reserved.
//

#import "CreditCardScannerNumberViewController.h"

#import "UIImage+OpenCV.h"

using namespace cv;
using namespace std;

@interface CreditCardScannerNumberViewController () {
    UIImage *cardNumImage;
}

@end

@implementation CreditCardScannerNumberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set opencv ios video processing framework
    
    // for debug init
    // self.videoCamera = [[CvVideoCamera alloc] init];
    
    // for preview init
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_previewImageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 15;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    
    // Get the graphics context
    UIGraphicsBeginImageContext(CGSizeMake(320., 480.));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draw the scanner window used for guiding people to scan properly ----- green
    CGContextSetRGBStrokeColor(ctx, 0, 255, 0, 1);
    CGContextSetLineWidth(ctx, 10);
    CGPoint points[3] = { CGPointMake(110, 340),
        CGPointMake(10, 340),
        CGPointMake(10, 280)};
    CGContextAddLines(ctx, points, 3);
    CGContextStrokePath(ctx);
    
    points[0] = CGPointMake(10, 210);
    points[1] = CGPointMake(10, 150);
    points[2] = CGPointMake(110, 150);
    CGContextAddLines(ctx, points, 3);
    CGContextStrokePath(ctx);
    
    points[0] = CGPointMake(210, 150);
    points[1] = CGPointMake(310, 150);
    points[2] = CGPointMake(310, 210);
    CGContextAddLines(ctx, points, 3);
    CGContextStrokePath(ctx);
    
    points[0] = CGPointMake(310, 280);
    points[1] = CGPointMake(310, 340);
    points[2] = CGPointMake(210, 340);
    CGContextAddLines(ctx, points, 3);
    CGContextStrokePath(ctx);
    
    CGContextSetRGBStrokeColor(ctx, 255, 0, 0, 0.5);
    CGContextSetLineWidth(ctx, 4);
    //card number rectange ----- red
    CGContextAddRect(ctx, CGRectMake(139.*300./1997., 622.*300./1997.+160., 1750.*300./1997., 192.*300./1997.));
    CGContextStrokePath(ctx);
    
    //expire month rectange ----- red
    CGContextAddRect(ctx, CGRectMake(991.*300./1997., 901.*300./1997.+160., 161.*300./1997., 132.*300./1997.));
    CGContextStrokePath(ctx);
    
    //expire year rectange ----- red
    CGContextAddRect(ctx, CGRectMake(1169.*300./1997., 901.*300./1997.+160., 177.*300./1997., 132.*300./1997.));
    CGContextStrokePath(ctx);
    
    //draw credit card edge sobel detection area to trigger the ocr processing automatically ----- blue
    CGContextSetRGBStrokeColor(ctx, 0, 0, 255, 0.5);
    CGContextSetLineWidth(ctx, 2);
    //top edge detection area
    CGContextAddRect(ctx, CGRectMake(1., 140., 318., 20.));
    CGContextStrokePath(ctx);
    //bottom edge detection area
    CGContextAddRect(ctx, CGRectMake(1., 330., 318., 20.));
    CGContextStrokePath(ctx);
    //right edge detection area
    CGContextAddRect(ctx, CGRectMake(301., 140., 18., 210.));
    CGContextStrokePath(ctx);
    //left edge detection area
    CGContextAddRect(ctx, CGRectMake(1., 140., 18., 210.));
    CGContextStrokePath(ctx);
    
    NSString *text1 = [NSString stringWithCString:"请将信用卡置于扫描框范围" encoding:NSUTF8StringEncoding];
    NSString *text2 = [NSString stringWithCString:"程序将自动为您扫描信用卡" encoding:NSUTF8StringEncoding];
    [text1 drawAtPoint:CGPointMake(50., 360.) forWidth:300. withFont:[UIFont fontWithName:@"Arial" size:18] fontSize:18 lineBreakMode:NSLineBreakByWordWrapping baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    [text2 drawAtPoint:CGPointMake(50., 380.) forWidth:300. withFont:[UIFont fontWithName:@"Arial" size:18] fontSize:18 lineBreakMode:NSLineBreakByWordWrapping baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 320., 480.)];
    imgView.backgroundColor = [UIColor clearColor];
    [imgView setImage:img];
    [self.view addSubview:imgView];
    [imgView release];
    
    // start capture
    [self.videoCamera start];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_previewImageView release];
    [_videoCamera release];
    [_debugImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPreviewImageView:nil];
    [self setVideoCamera:nil];
    [self setDebugImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Protocol CvVideoCameraDelegate

- (void)processImage:(Mat&)image
{
    // Do some OpenCV stuff with the image
    NSLog(@"%@", @"call delegate");
    Mat image_gray;
    Mat image_canny;
    cvtColor(image, image_gray, CV_BGR2GRAY);
    Canny(image_gray, image_canny, 30, 100);
    
    cv::Rect creditCardROI(10.*480./320.,140.*640./480.*9./8.,300.*480./320.,190.*640./480.*9./8.);
    cv::Rect creditCardNumverROI(139.*300./1997.*480./320.,(480 - (622.*300./1997.+160))*640./480.*9./8.,1750.*300./1997.*480./320.,192.*300./1997.*640./480.*9./8.);
    Mat image_crop = image_gray(creditCardROI);
    Mat image_number = image_gray(creditCardNumverROI);
//    UIImage *previewImage = [UIImage imageWithCVMat:image_canny];
    //UIImage *debugImage = [UIImage imageWithCVMat:image_crop];
//    Mat results;
//    int blockDim=MIN( image_number.size().height/4, image_number.size().width/4);
//    if(blockDim % 2 != 1) blockDim++;   //block has to be odd
//    cv::adaptiveThreshold(image_number, results, 255, cv::ADAPTIVE_THRESH_MEAN_C,
//                          cv::THRESH_BINARY,blockDim, 0);
//    cardNumImage = [UIImage imageWithCVMat:results];
    //image.release();
    
    //hough lines
    Mat lineOut;
    vector<Vec2f> lines;
    HoughLines(image_canny, lines, 1, CV_PI/180, 150);
    
    //draw the lines on image
    for( size_t i = 0; i < lines.size(); i++ )
    {
        float rho = lines[i][0];
        float theta = lines[i][1];
        double a = cos(theta), b = sin(theta);
        if ((b/a) < tan(10*CV_PI/180) && (b/a) > tan(-10*CV_PI/180)) {
            double x0 = a*rho, y0 = b*rho;
            cv::Point pt1(cvRound(x0 + 1000*(-b)),
                          cvRound(y0 + 1000*(a)));
            cv::Point pt2(cvRound(x0 - 1000*(-b)),
                          cvRound(y0 - 1000*(a)));
            line( image, pt1, pt2, Scalar(0,0,255), 2, 8 );
        }
        if ((b/a) > tan(80*CV_PI/180) || (b/a) < tan(100*CV_PI/180)) {
            double x0 = a*rho, y0 = b*rho;
            cv::Point pt1(cvRound(x0 + 1000*(-b)),
                          cvRound(y0 + 1000*(a)));
            cv::Point pt2(cvRound(x0 - 1000*(-b)),
                          cvRound(y0 - 1000*(a)));
            line( image, pt1, pt2, Scalar(0,0,255), 2, 8 );
        }
    }
    
    //cardNumImage = [UIImage imageWithCVMat:image];
    
    image_gray.release();
    image_canny.release();
    image_crop.release();
    image_number.release();
    lineOut.release();
    //results.release();
//    dispatch_sync(dispatch_get_main_queue(),^{
////        _previewImageView.image = previewImage;
//        _debugImageView.image = cardNumImage;
////        [previewImage release];
//        //[debugImage release];
//        [cardNumImage release];
//    });
}

- (IBAction)test:(id)sender {
    tesseract::TessBaseAPI *tesseract = new tesseract::TessBaseAPI();
    
    tesseract->Init([[self pathToLangugeFIle] cStringUsingEncoding:NSUTF8StringEncoding], "eng");
    tesseract->SetVariable("tessedit_char_whitelist", "0123456789");
    
    //Pass the UIIMage to cvmat and pass the sequence of pixel to tesseract
    
    Mat toOCR=[cardNumImage CVMat];
    
    NSLog(@"%d", toOCR.channels());
    
    tesseract->SetImage((uchar*)toOCR.data, toOCR.size().width, toOCR.size().height
                        , toOCR.channels(), toOCR.step1());
    
    tesseract->Recognize(NULL);
    
    char* utf8Text = tesseract->GetUTF8Text();
    
    NSLog(@"%@",[NSString stringWithUTF8String:utf8Text]);
}

- (NSString*) pathToLangugeFIle{
    
    // Set up the tessdata path. This is included in the application bundle
    // but is copied to the Documents directory on the first run.
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([documentPaths count] > 0) ? [documentPaths objectAtIndex:0] : nil;
    
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"tessdata"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:dataPath]) {
        // get the path to the app bundle (with the tessdata dir)
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
        if (tessdataPath) {
            [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
        }
    }
    
    setenv("TESSDATA_PREFIX", [[documentPath stringByAppendingString:@"/"] UTF8String], 1);
    
    return dataPath;
}

@end