//
//  Entity.h
//  RecipeShare
//
//  Created by SongShiyu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * process1;
@property (nonatomic, retain) NSString * process2;
@property (nonatomic, retain) NSString * process3;
@property (nonatomic, retain) NSString * ingredient;
@property (nonatomic, retain) NSString * image;

@end
