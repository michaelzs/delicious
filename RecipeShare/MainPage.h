//
//  MainPage.h
//  RecipeShare
//
//  Created by SongShiyu on 4/25/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface MainPage : UITableViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, strong) NSMutableArray *tableData;

@property (nonatomic, strong)NSIndexPath *cellSelect;
@property (nonatomic, strong)NSString *uID;

@end
