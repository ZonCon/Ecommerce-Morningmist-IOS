//
//  ImageScreenViewController.m
//  Metasurgasia
//
//  Created by Hrushikesh  on 21/06/14.
//  Copyright (c) 2014 MeGo Technologies. All rights reserved.
//

#import "globals.h"
#import "DbHelper.h"
#import "NavigationViewController.h"
#import "SyncViewController.h"
#import "ImageScreenViewController.h"

@interface ImageScreenViewController ()

@end

@implementation ImageScreenViewController

@synthesize newsImage = _newsImage;
@synthesize scrollView = _scrollView;
@synthesize image = _image;

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
    // Do any additional setup after loading the view.
    
    NSLog(@"Image = %@", _image);
    
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 2.0;
    self.scrollView.delegate=self;
    
    if(_image.length > 0) {
        
        NSString *pictureUrl = [NSString stringWithFormat:@"%@%@%@", SERVER, UPLOADS, _image];
        NSLog(@"Displaying Downloading picture=%@==", pictureUrl);
        NSURL *url = [NSURL URLWithString:pictureUrl];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             
             if(error == nil) {
                 
                 UIImage *original=[UIImage imageWithData:data];
                 UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:1.0 orientation:original.imageOrientation];
                 _newsImage.image=small;
                 
             }
             
         }];
        
    } else {
        _newsImage.image = [UIImage imageNamed: @"cover.jpg"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _newsImage;
}

-(IBAction)Save:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
    });
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"Saved successfully in the library!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(IBAction)Close:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
