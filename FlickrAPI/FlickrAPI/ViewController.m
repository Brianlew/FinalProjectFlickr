//
//  ViewController.m
//  FlickrAPI
//
//  Created by Brian Lewis on 5/28/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UISegmentedControl *tagOrLocationControlOutlet;
        
    NSString *ApiKey;
    NSString *ApiSecret;
    NSArray *photosArray;
    
    int imageCounter;
}
- (IBAction)nextPhoto:(id)sender;
- (IBAction)tagOrLocationControl:(id)sender;

-(void)getPhotosFromFlickr;
-(void)displayNextPhoto;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    ApiKey = @"4285143b45794604189ae812ab052343";
    ApiSecret = @"eeff2d90b373858a";
    
    activityIndicator.color = [UIColor blueColor];

    [self getPhotosFromFlickr];
}

-(void)getPhotosFromFlickr
{
    imageCounter = 0;
    
    //http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4285143b45794604189ae812ab052343&tags=goblue
    
    [activityIndicator startAnimating];
    
    NSString *urlString;

    if (tagOrLocationControlOutlet.selectedSegmentIndex == 0) {
    //search by tag
    NSString *tags = @"goblue";
    urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=%@&tags=%@", ApiKey, tags];
    }
    else {
    /*search by location*/
    CGFloat latitude = 28.418793; //Cinderella's Castle at Disney World's Magic Kingdom
    CGFloat longitude = -81.581201;
    
    urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&min_upload_date=20130201&lat=%f&lon=%f&radius=30&format=json&nojsoncallback=1", ApiKey, latitude, longitude];
    }
    
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *photos = [responseDictionary objectForKey:@"photos"];
        photosArray = [photos objectForKey:@"photo"];
        
        [activityIndicator stopAnimating];
        activityIndicator.color = [UIColor whiteColor];
        
        [self displayNextPhoto];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextPhoto:(id)sender {
    imageCounter++;
    [self displayNextPhoto];
}

- (IBAction)tagOrLocationControl:(id)sender {
    [self getPhotosFromFlickr];
}

-(void)displayNextPhoto
{
    NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg", [photosArray[imageCounter] objectForKey:@"farm"], [photosArray[imageCounter] objectForKey:@"server"], [photosArray[imageCounter] objectForKey:@"id"], [photosArray[imageCounter] objectForKey:@"secret"]];
    
    NSLog(@"%@", photoURLString);
    NSURL *photoUrl = [NSURL URLWithString:photoURLString];
    NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
    
    NSLog(@"Image %i of %i", imageCounter, photosArray.count);
    imageView.image = [UIImage imageWithData:photoData];
}

@end
