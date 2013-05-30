//
//  ViewController.m
//  FlickSquare
//
//  Created by Natasha Murashev on 5/28/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "MapViewController.h"
#import "Foursquare2.h"
#import "Venue.h"
#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"
#import "DetailViewController.h"

@interface MapViewController ()
{
    
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    CLLocationManager *locationMananger;
    
    NSMutableArray *venuesArray;
}

//-(void)showCurrentLocation:(CLLocation *)location;
-(void)addPinToLocation:(CLLocationCoordinate2D)location;
-(void)addVenueAnnotation:(Venue*)venue;

@end

@implementation MapViewController
@synthesize photoCoordinate, mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [activityIndicator startAnimating];
    
    venuesArray = [NSMutableArray array];
    
//    locationMananger = [[CLLocationManager alloc] init];
//    locationMananger.delegate = self;
//    
//    [locationMananger startUpdatingLocation];
    
//    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(41.89374, -87.63533);
        
    MKCoordinateSpan span = MKCoordinateSpanMake(.001, .001);
    MKCoordinateRegion region = MKCoordinateRegionMake(photoCoordinate, span);
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = photoCoordinate;
    
    mapView.region = region;
    [mapView addAnnotation:pointAnnotation];
    
    self.mapTypeControl.selectedSegmentIndex = 2;
    mapView.mapType = 2;

    
    [self getFoursquareVenuesWithLatitude:photoCoordinate.latitude andLongitude:photoCoordinate.longitude];
}

- (void)getFoursquareVenuesWithLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude
{
       
    [Foursquare2 searchVenuesNearByLatitude:[NSNumber numberWithFloat:latitude]
                                  longitude:[NSNumber numberWithFloat:longitude]
                                 accuracyLL:nil
                                   altitude:nil
                                accuracyAlt:nil
                                      query:nil
                                      limit:[NSNumber numberWithInt:100]
                                     intent:0
                                     radius:[NSNumber numberWithInt:800]
                                 categoryId:nil
                                   callback:^(BOOL success, id result) {
                                       
                                       if (success) {
                                           
                                           NSArray *apiVenuesArray = [result valueForKeyPath:@"response.venues"];
                                           
                                           for (NSDictionary *venue in apiVenuesArray) {
                                               
                                               Venue *newVenue = [[Venue alloc] init];
                                               
                                               newVenue.name = [venue objectForKey:@"name"];
                                               newVenue.latitude = [[venue valueForKeyPath:@"location.lat"] floatValue];
                                               newVenue.longitude = [[venue valueForKeyPath:@"location.lng"] floatValue];
                                               
                                               [venuesArray addObject:newVenue];
                                               
                                               [self addVenueAnnotation:newVenue];
                                            }
                                       
                                        } else {
                                            
                                            NSLog(@"ERROR: %@", result);
         
                                        }
                                        [activityIndicator stopAnimating];
                                   }];
    
}

-(void)addVenueAnnotation:(Venue*)venue
{
    
    VenueAnnotation* venueAnnotation = [[VenueAnnotation alloc] init];
    
    venueAnnotation.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude);
    venueAnnotation.title = venue.name;
    venueAnnotation.venue = venue;
    
    [mapView addAnnotation:venueAnnotation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    NSString* venueIdentifier = @"venue";
    NSString* pinIdentifier = @"pin";
    
    
    MKAnnotationView* annotationView;
    
    if ([annotation isKindOfClass:[VenueAnnotation class]]) {
        annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:venueIdentifier];
        
    } else {
        annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        
        
    }
    
    if(!annotationView) {
        if ([annotation isKindOfClass:[VenueAnnotation class]]) {
            annotationView = [[VenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:venueIdentifier];
            
        } else {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
            ((MKPinAnnotationView*)annotationView).animatesDrop = YES;
        }
        annotationView.canShowCallout = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
    } else {
        
        annotationView.annotation = annotation;
        
    }
    
    return  annotationView;
    
}

- (void)addPinToLocation:(CLLocationCoordinate2D)location
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:location];
    [mapView addAnnotation:annotation];
}

/*- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    [self performSegueWithIdentifier:@"mapToDetail" sender:self];
    
}*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VenueAnnotation* venueAnnotation = [mapView selectedAnnotations][0];
    Venue* venue = venueAnnotation.venue;
    ((DetailViewController*)segue.destinationViewController).venue = venue;
    
}

#pragma mark - Location manager

//-(void)showCurrentLocation:(CLLocation *)location
//{
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.001;
//    span.longitudeDelta = 0.001;
//    
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
//    
//    MKCoordinateRegion region;
//    region.span = span;
//    region.center=center;
//    
//    [_mapView setRegion:region animated:TRUE];
//    [_mapView regionThatFits:region];
//    
//    [self addPinToLocation:center];
//}


//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    CLLocation *location = locations[0];
//
//    [self showCurrentLocation:location];
//    
//    [self getFoursquareVenuesWithLatitude:(CGFloat)location.coordinate.latitude
//                             andLongitude:(CGFloat)location.coordinate.longitude];
//    
//    [locationMananger stopUpdatingLocation];
//}


- (IBAction)changeMapType:(id)sender {
    
    mapView.mapType = self.mapTypeControl.selectedSegmentIndex;
}
@end
