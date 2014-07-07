//
//  Favorite.h
//  RecipeShare
//
//  Created by SongShiyu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface Favorite : UITableViewController

@property (nonatomic, strong)NSMutableArray *dataTable;
@property (nonatomic, strong)NSIndexPath *cellChosen;
@property NSString *name;
@property NSString *ingredient;
@property NSString *image;
@property NSString *process1;
@property NSString *process2;
@property NSString *process3;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property NSMutableArray *entityArray;

@end
