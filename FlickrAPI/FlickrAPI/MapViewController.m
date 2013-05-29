//
//  MapViewController.m
//  FlickrAPI
//
//  Created by Brian Lewis on 5/29/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
{
    NSString *ApiKey;
    NSString *ApiSecret;
    
    CLLocationCoordinate2D photoCoordinate;
}
-(void)showLocationOnMap;
@end

@implementation MapViewController
@synthesize photoCoordinate, mapView;

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
    
    ApiKey = @"4285143b45794604189ae812ab052343";
    ApiSecret = @"eeff2d90b373858a";
    
    [self showLocationOnMap];
}

-(void)showLocationOnMap
{
    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
    MKCoordinateRegion region = MKCoordinateRegionMake(photoCoordinate, span);
    mapView.region = region;
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = photoCoordinate;
        
    [mapView addAnnotation:pointAnnotation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToPhotoView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (IBAction)changeMapType:(UISegmentedControl*)sender {
    mapView.mapType = sender.selectedSegmentIndex; //0 for std, 1 for sat, 2 for hybrid
}
@end
