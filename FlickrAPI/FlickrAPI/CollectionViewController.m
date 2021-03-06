//
//  CollectionViewController.m
//  FlickrAPI
//
//  Created by Brian Lewis on 5/30/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "CollectionViewController.h"
#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CollectionViewCell.h"

@interface CollectionViewController ()
{
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIView *searchView;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UILabel *noResultsLabel;

    NSString *ApiKey;
    NSString *ApiSecret;
    NSArray *photosArray;
    NSMutableArray *imageArray;
    
    UIImage *previousImage;
    UIImage *currentImage;
    UIImage *nextImage;
    
    int imageCounter;
    CLLocationCoordinate2D photoCoordinate;
    
    NSOperationQueue *operationQueue;
    int maxPreload;
}

-(void)getPhotosFromFlickr;
-(void)getPhotoGeoLocation:(NSString*)photoId forCell:(CollectionViewCell*)cell;

- (IBAction)goToMap:(id)sender;
- (IBAction)showSearchView:(id)sender;
- (IBAction)searchWithNewTag:(id)sender;
@end

@implementation CollectionViewController
@synthesize collectionView;

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
    
    ApiKey = @"4285143b45794604189ae812ab052343";
    ApiSecret = @"eeff2d90b373858a";
    
    imageArray = [[NSMutableArray alloc] init];
    operationQueue = [[NSOperationQueue alloc] init];
    maxPreload = 3;
    
    searchView.layer.cornerRadius = 8;
    noResultsLabel.layer.cornerRadius = 5;
    noResultsLabel.hidden = YES;
}

- (IBAction)showSearchView:(id)sender {
    [searchTextField becomeFirstResponder];
    [UIView animateWithDuration:.5 animations:^{
        searchView.alpha = 1;
    }];
}

- (IBAction)searchWithNewTag:(id)sender {
    [UIView animateWithDuration:.5 animations:^{
        searchView.alpha = 0;
    }];
    [searchTextField resignFirstResponder];
    [imageArray removeAllObjects];
    noResultsLabel.hidden = YES;
    
    NSLog(@"\n\n\n\n\n\nNEW SEARCH");
    [self getPhotosFromFlickr];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchWithNewTag:self];
    return YES;
}

-(void)getPhotosFromFlickr
{
    imageCounter = 0;
    
    [activityIndicator startAnimating];
    
    NSString *urlString;
    
    NSString *tags = searchTextField.text;  //@"SearsTower";
    NSString *encodedTags = [tags stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=%@&tags=%@", ApiKey, encodedTags];
    
   /*     CGFloat latitude = 28.418793; //Cinderella's Castle at Disney World's Magic Kingdom
        CGFloat longitude = -81.581201;
        
        urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&min_upload_date=20130201&lat=%f&lon=%f&radius=30&format=json&nojsoncallback=1", ApiKey, latitude, longitude];
    
    */
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *photos = [responseDictionary objectForKey:@"photos"];
        photosArray = [photos objectForKey:@"photo"];
        
        [activityIndicator stopAnimating];
        
        if (photosArray.count == 0) {
            NSLog(@"\n\nno results found");
            [self showSearchView:self];
            noResultsLabel.text = [NSString stringWithFormat:@"No Photos for\n\"%@\"", searchTextField.text];
            collectionView.alpha = 0;
            noResultsLabel.hidden = NO;
        }
        else{
            [UIView animateWithDuration:.5 animations:^{
                collectionView.alpha = 1;
            }];
        }
        
        [collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1)
                                animated:NO];
        
        [collectionView reloadData];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToMap:(id)sender {
    [self performSegueWithIdentifier:@"mapSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((MapViewController*)segue.destinationViewController).photoCoordinate = photoCoordinate;
}

-(void)getPhotoGeoLocation:(NSString*)photoId forCell:(CollectionViewCell*)cell
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
            
            cell.mapButton.hidden = NO;
        }
        
    }];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSLog(@"Number of photo details coming back: %i", photosArray.count);
    return photosArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    CollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.mapButton.hidden = YES;
    cell.mapButton.layer.cornerRadius = 5;
    cell.mapButton.clipsToBounds = YES;
        
    NSLog(@"array count: %i , index: %i", imageArray.count, indexPath.item);
    
    if (imageArray.count <= indexPath.item && imageArray.count < photosArray.count) {
        
        NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg", [photosArray[indexPath.item] objectForKey:@"farm"], [photosArray[indexPath.item] objectForKey:@"server"], [photosArray[indexPath.item] objectForKey:@"id"], [photosArray[indexPath.item] objectForKey:@"secret"]];
        
        NSLog(@"%@", photoURLString);
        NSURL *photoUrl = [NSURL URLWithString:photoURLString];
        NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
        
        UIImage *image = [UIImage imageWithData:photoData];
        
        cell.imageView.image = image;
        [imageArray addObject:image];
    }
    else {
        if (imageArray.count >= indexPath.item) {
            cell.imageView.image = imageArray[indexPath.item];
        }
    }
    
        
    NSLog(@"Image %i of %i", indexPath.item, photosArray.count);
    
    int preloadCount = imageArray.count - indexPath.item;

    if (preloadCount < maxPreload) {
        [self preloadPhotos:indexPath.item currentPreloadCount:preloadCount];
    }
    
    [self getPhotoGeoLocation:[photosArray[indexPath.item] objectForKey:@"id"] forCell:cell];
    
    return cell;
}

-(void)preloadPhotos:(int)indexItem currentPreloadCount:(int)preloadCount
{    
    for (int i=preloadCount; i < maxPreload; i++) {
        if (imageArray.count < photosArray.count) {
            
            NSLog(@"array count: %i , index: %i", imageArray.count, indexItem);
            
            NSBlockOperation *getNextPhotoOperation = [NSBlockOperation blockOperationWithBlock:^{
                
                NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg", [photosArray[indexItem+i] objectForKey:@"farm"], [photosArray[indexItem+i] objectForKey:@"server"], [photosArray[indexItem+i] objectForKey:@"id"], [photosArray[indexItem+i] objectForKey:@"secret"]];
                
                NSLog(@"%@", photoURLString);
                NSURL *photoUrl = [NSURL URLWithString:photoURLString];
                NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
                UIImage *image = [UIImage imageWithData:photoData];
                
                NSBlockOperation *updateCollectionViewOperation = [NSBlockOperation blockOperationWithBlock:^{
                    [imageArray replaceObjectAtIndex:indexItem+i withObject:image];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:indexItem+i inSection:0];
                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }];
                
                [[NSOperationQueue mainQueue] addOperation:updateCollectionViewOperation];
                
                NSLog(@"done");
            }];
            
            [imageArray addObject:[UIImage imageNamed:@"imageLoading.jpg"]];
            [operationQueue addOperation:getNextPhotoOperation];
        }
    }
}


@end
