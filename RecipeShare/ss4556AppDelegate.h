//
//  ss4556AppDelegate.h
//  RecipeShare
//
//  Created by SongShiyu on 4/25/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entity.h"

@interface ss4556AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong,nonatomic) NSString *username;
@property (strong,nonatomic) NSString *password;
@property (strong,nonatomic) NSMutableArray *followed;
@property (strong,nonatomic) NSMutableArray *follow;
@property (strong,nonatomic) Entity *entity;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
