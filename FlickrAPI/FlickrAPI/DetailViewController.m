//
//  DetailViewController.m
//  FlickSquare
//
//  Created by Jesse Tello on 5/29/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
{
    NSMutableArray* imageArray;
}


@end

@implementation DetailViewController

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
    self.navigationItem.title = self.venue.name;
    
    imageArray = [NSMutableArray array];
}


- (void)setVenue:(Venue *)venue
{
    _venue = venue;
    
   // [self getFlickrPhotos];
}


/*- (void)getFlickrPhotos
{
    NSString* flickrURLString = [NSString stringWithFormat:@"%@&method=flickr.photos.search&api_key=%@&bbox=%f,%f,%f,%f&format=json&nojsoncallback=1",FLICKR_BASE_URL, FLICKR_API_KEY, self.venue.longitude - .01, self.venue.latitude - .01,self.venue.longitude + .01,self.venue.latitude + .01];
    
    NSURL* url = [NSURL URLWithString:flickrURLString];
    
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
                               
                               if (!error) {
                                   
                                   NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                       
                                   NSArray* photosArray = [responseDictionary valueForKeyPath:@"photos.photo"];
                                   
                                   
                                   for (NSDictionary* photoDictionary in photosArray) {
                                    
                                   
                                   NSString* photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_m.jpg",
                                                         [photoDictionary objectForKey:@"farm"],
                                                         [photoDictionary objectForKey:@"server"],
                                                         [photoDictionary objectForKey:@"id"],
                                                         [photoDictionary objectForKey:@"secret"]];
                                       
                                       NSLog(@"%@",photoURLString);
                                       
                                       UIImage* image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]]];
                                       
                                       [imageArray addObject:image];
                                       
                                       
                                   }
                                   
                               } else {
                                   NSLog(@"%@",error);
                               }
                                   
                               
                               
                               
                               
                           }];
}*/

@end
