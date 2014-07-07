//
//  MyRecipeTableViewController.h
//  RecipeShare
//
//  Created by Zhan Shu on 4/29/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "ACPButton.h"

@interface MyRecipeTableViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (strong, nonatomic) IBOutlet UITableView *recipeTableview;
@property (nonatomic, strong)NSIndexPath *cellSelect;
@property (nonatomic, strong)NSString *uID;
@property (strong, nonatomic) IBOutlet ACPButton *logoutbutton;
@property (strong, nonatomic) IBOutlet ACPButton *addreciepe;



@end
