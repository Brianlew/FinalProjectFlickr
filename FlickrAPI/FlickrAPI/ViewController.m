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
        
    NSString *ApiKey;
    NSString *ApiSecret;
    NSArray *photosArray;
    
    int imageCounter;
}

-(void)getPhotosFromFlickr;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    ApiKey = @"4285143b45794604189ae812ab052343";
    ApiSecret = @"eeff2d90b373858a";
    imageCounter = 0;
    
    [self getPhotosFromFlickr];
}

-(void)getPhotosFromFlickr
{
    //http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4285143b45794604189ae812ab052343&tags=goblue
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=%@&tags=goblue", ApiKey];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *photos = [responseDictionary objectForKey:@"photos"];
        photosArray = [photos objectForKey:@"photo"];
                
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
