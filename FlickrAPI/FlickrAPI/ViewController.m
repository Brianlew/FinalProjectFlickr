//
//  ViewController.m
//  FlickrAPI
//
//  Created by Brian Lewis on 5/28/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
{
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UISegmentedControl *tagOrLocationControlOutlet;
    __weak IBOutlet UIButton *mapButton;
        
    NSString *ApiKey;
    NSString *ApiSecret;
    NSArray *photosArray;
    
    int imageCounter;
    CLLocationCoordinate2D photoCoordinate;
}
- (IBAction)nextPhoto:(id)sender;
- (IBAction)tagOrLocationControl:(id)sender;
- (IBAction)goToMapViewController:(id)sender;

-(void)getPhotosFromFlickr;
-(void)displayNextPhoto;
-(void)getPhotoGeoLocation:(NSString*)photoId;
-(void)setUpGestureRecognizers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    ApiKey = @"4285143b45794604189ae812ab052343";
    ApiSecret = @"eeff2d90b373858a";
    
    tagOrLocationControlOutlet.selectedSegmentIndex = 1;
    mapButton.layer.cornerRadius = 7;
    mapButton.clipsToBounds = YES;

    mapButton.hidden = YES;
    activityIndicator.color = [UIColor blueColor];

    [self setUpGestureRecognizers];
    [self getPhotosFromFlickr];
}

-(void)getPhotosFromFlickr
{
    imageCounter = 0;
        
    [activityIndicator startAnimating];
    
    NSString *urlString;

    if (tagOrLocationControlOutlet.selectedSegmentIndex == 0) {
    //search by tag
    NSString *tags = @"SearsTower";
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
    if (imageCounter >= photosArray.count) {
        imageCounter = 0;
    }
    [self displayNextPhoto];
}

-(void)previousPhoto
{
    imageCounter--;
    if (imageCounter < 0) {
        imageCounter = photosArray.count - 1;
    }
    [self displayNextPhoto];
}

- (IBAction)tagOrLocationControl:(id)sender {
    [self getPhotosFromFlickr];
}

- (IBAction)goToMapViewController:(id)sender {
    [self performSegueWithIdentifier:@"mapSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((MapViewController*)segue.destinationViewController).photoCoordinate = photoCoordinate;
}

-(void)displayNextPhoto
{
    mapButton.hidden = YES;
    
    NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg", [photosArray[imageCounter] objectForKey:@"farm"], [photosArray[imageCounter] objectForKey:@"server"], [photosArray[imageCounter] objectForKey:@"id"], [photosArray[imageCounter] objectForKey:@"secret"]];
    
    NSLog(@"%@", photoURLString);
    NSURL *photoUrl = [NSURL URLWithString:photoURLString];
    NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
    
    NSLog(@"Image %i of %i", imageCounter, photosArray.count);
    imageView.image = [UIImage imageWithData:photoData];
    
    [self getPhotoGeoLocation:[photosArray[imageCounter] objectForKey:@"id"]];
}

-(void)getPhotoGeoLocation:(NSString*)photoId
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", ApiKey,photoId];
    
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([[responseDictionary objectForKey:@"stat"] isEqual:@"ok"]) {
            NSDictionary *photo = [responseDictionary objectForKey:@"photo"];
            NSDictionary *location = [photo objectForKey:@"location"];
            
            CGFloat latitude = [[location objectForKey:@"latitude"] floatValue];
            CGFloat longitude = [[location objectForKey:@"longitude"] floatValue];
            
            photoCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            mapButton.hidden = NO;
        }
        
    }];
    
}

-(void)setUpGestureRecognizers
{
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPhoto:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    leftGesture.delegate = self;
    [self.view addGestureRecognizer:leftGesture];

    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousPhoto)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    rightGesture.delegate = self;
    [self.view addGestureRecognizer:rightGesture];
}






@end
