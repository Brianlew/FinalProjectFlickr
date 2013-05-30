//
//  ViewController.h
//  FlickSquare
//
//  Created by Natasha Murashev on 5/28/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D photoCoordinate;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
