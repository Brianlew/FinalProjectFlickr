//
//  MapViewController.h
//  FlickrAPI
//
//  Created by Brian Lewis on 5/29/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController 

@property CLLocationCoordinate2D photoCoordinate;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)backToPhotoView:(id)sender;
@end
