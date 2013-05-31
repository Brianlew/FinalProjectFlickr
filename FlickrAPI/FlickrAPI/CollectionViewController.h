//
//  CollectionViewController.h
//  FlickrAPI
//
//  Created by Brian Lewis on 5/30/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
