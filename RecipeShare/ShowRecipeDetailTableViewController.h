//
//  ShowRecipeDetailTableViewController.h
//  RecipeShare
//
//  Created by Zhan Shu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface ShowRecipeDetailTableViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) NSDictionary *detailData;

@property NSString *flag;
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, retain) NSMutableArray *commentdata;

@end
